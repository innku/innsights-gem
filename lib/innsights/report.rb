require 'resque'

module Innsights
  # This class receives raw information and objects, then it formats them to be used with the service API
  # the class uses the configuration set through `Innsights.user` and `Innsights.group` methods to fetch
  # the information from the user and group objects
  # 
  # @attr [String] name the name of the reported action
  # @attr [Object, nil] user the user record actor in the action
  # @attr [Object, nil] group the group that the actor user of the action belongs to
  # @attr [Time] created_at time at which the action ocurred
  # @attr [Hash] hash of metrics the action is affecting
  # @example 
  #   # The only thing mandatory for a report is the name
  #   Innsights::Report.new('Create post')
  #   # However you can specify user, group, metrics and created_at time 
  #   Innsights::Report.new('Create Post', :user => User.find(1)).run # => [response from API service]
  #   Innsights::Report.new('Format Document', :measure => {:loc => 200}) # => [response from API service]
  class Report

    attr_accessor :name, :user, :created_at, :metrics

    # Sets up every part of the report with the options given
    # @param [String] name the name of the action being reported
    # @param [Hash] options the options hash containing all the reports attributes
    # @note the default method for created_at is the current time
    # @todo created_at default should be formatted to unix timestamp as soon as Innsights accepts it
    def initialize(name, options=nil)
      options ||= {}
      @name = name
      @user_object = options[:user]
      @group_object = fetch_group(options)
      @created_at = options[:created_at] || Time.now
      @metrics = options[:measure] || {}
    end

    # Hashed value prepared for posting to service via the client class
    # 
    # @return [Hash] contains values for name, created_at, user, group and metrics
    # @example for a full report
    #   report = Innsights::Reports.new('Publish Post')
    #   report.to_hash # => {report: {name: 'Publish Post', created_at: 2012-10-09 16:19:06 -0400 } }
    def to_hash
      value = {name: name, created_at: created_at}
      value.merge!({user: user.to_hash})   if user.present?
      value.merge!({group: group.to_hash}) if group.present?
      value.merge!({metrics: metrics})     if metrics.present?
      {:report => value}
    end

    # Posts the prepared report information to Innsights
    # It is required to execute this method for posting a report action to the API Service
    # Will either queue or not depending on user configuration
    # 
    # @example
    #   report = Innsights::Report.new('Buy product', measure: {price: 299.0})
    #   # The following line will post the report
    #   report.run
    def run
      if Innsights.enabled?
        case Innsights.queue_system
          when :resque; Resque.enqueue(Innsights::Jobs::RunReport, self.to_hash)
          when :delayed_job; Innsights.client.delay.report(self.to_hash)
          else; Innsights.client.report(self.to_hash)
        end
      end
    end

    # An encapsulation object of the group that the user that performs the action belongs to.
    # If the user configuration contains a group, it will call this method
    # to get the user object, if the report explicitly sets the group attribute
    # it will supercede the user configuration
    #
    # @return [Innsights::Fetchers::Group, nil] User group object, nil if no explicit or user configuration
    def group
      @group ||= Innsights::Fetchers::Group.new(@group_object) if @group_object
    end

    # An encapsulation object of the user that performs the action
    # 
    # @return [Innsights::Fetchers::User, nil] User object, nil if no explicit user given
    def user
      @user ||= Innsights::Fetchers::User.new(@user_object) if @user_object
    end

    private

    def fetch_group(options)
      return options[:group] if options.has_key? :group
      return user.group if user.present?
      nil
    end

  end
end
