# @attr [String, Symbol] name report name being sent to Service
# @attr [String, Symbol] created_at timestamp attribute of the watched class
# @user [String, Symbol] user attribute of the watched class
# @metrics [Hash] hash of metrics where the key is the name of the metric, and the value is the method of the record that gets the metric
module Innsights
  module Config
    class Base
      include Helpers::Config

      attr_accessor :name, :created_at_method, :report_user, :report_group, :metrics, :condition
      
      # @!macro [attach] inn.dsl
      # @!method $1(value, &block)
      # DSL method that takes the $1 value, method name or eval block and sets the $2 property
      dsl :user,       :report_user
      dsl :group,      :report_group
      dsl :created_at, :created_at_method

      # Creates a prepared report for the service and runs it
      #
      # @param [Object] instance the record or the controller instance from which the values will be fetched
      # @example
      #   post = Post.create(title: 'New post', user: user)
      #   example_report.new(Post).run(post) # => Response data
      #
      #   controller = UsersController.new
      #   example_report.new(UsersController).run(controller) # => Response data
      def run(instance)
        instance = Innsights::Fetchers::Record.new(instance, self)
        Innsights::Report.new(instance.name, instance.options).run if instance.run?
      end

      # DSL attribute to set the report name
      # optionally receives an if condition block that evaluates whether or not to send the report
      #
      # @param [Symbol,String,Proc] name the name of the report sent to the Service
      # @param [Hash] options hash of options for the report name
      # @option options [Proc] :if process that evaluate if the report will be sent. 
      #   Yields the record object and should output nil or false if the object is not to be sent, anything else for it to be sent
      # @example
      #   example_report = Config::ModelReport.new(Post)
      #   example_report.report "New Post", if: lambda {|record| record.should_report? } # => <#ModelReport @name="New Post" @condition=<#Proc..>...>
      def report(name, options={})
        @name = name
        @condition = options[:if]
        self
      end

      # DSL attribute that sets any number of metrics measured in the given report
      # optionally receives the :with option with the name of the method to call
      #
      # @param [String, Symbol] name the name of the metric
      # @param [Hash] options method options
      # @option options [Symbol] :with name of the method to call in the record
      # @example
      #   example_report = Config::ModelReport.new(Property)
      #   example_report.measure(:rooms)
      #   example_report.metrics # => {rooms: :rooms}
      #   example_report.measure("Area", with: :km2)
      #   example_report.metrics # => {"Area": :km2}
      def measure(name, options={})
        options ||= {with: name}
        metrics.merge!({name.to_sym => options[:with]})
        self
      end

      # Sets up the configured report and returns the prepared proc for callback
      # works for either active_record style callbacks or after_filters
      #
      # @param [Class] receiver the receiver class that holds the callback method for its instances
      # @return [Proc] process ready to inject into callback method
      # @example
      #   config.name = "Create post"
      #   config.setup(UsersController) # =>  <#Proc...>
      #   UsersController.innsights[reports] # => <#Innsights::Config::Controller...>
      def setup(receiver)
        Innsights.reports << self
        receiver.cattr_accessor :innsights_reports unless receiver.respond_to?(:insights_reports)
        receiver.innsights_reports ||= {}
        receiver.innsights_reports[name] = self
        name = self.name
        lambda {|instance| innsights_reports[name].run(instance) }
      end

      # By default all reports are invalid for push
      # 
      # @return [False] a report is by default invalid for push
      def valid_for_push?
        false
      end

    end
  end
end