require 'resque'
require_relative './workers/run_report'
module Innsights
  class Config::CustomReport
    include Helpers::Config

    dsl_attr :event_name,  :catalyst #users#create
    dsl_attr :action_name, :report #User created
    dsl_attr :created_at,  :timestamp
    dsl_attr :report_user, :user #current_dude

    attr_accessor :controller, :action, :klass

    def initialize(catalyst)
      @controller, @action = catalyst.split('#')
      @catalyst = catalyst
      @created_at = :created_at
      @event_name = :create
      @report_user = :user
    end

    def commit
      report, report_action = self, @action_name
      klass = "#{@controller.titleize}Controller".safe_constantize
      unless klass.nil?
        Innsights.reports << report
        add_report_to_innsights(klass, report_action, report)
        add_after_filter(klass, action)
      end
    end


    def add_report_to_innsights(klass, report_action, report)
      klass.instance_eval do
        cattr_accessor :innsights_reports unless defined?(@@insights_reports)
        self.innsights_reports ||= {}
        self.innsights_reports[report_action] = report
        send :define_method, "report_to_innsights" do
          lambda {|r| self.innsights_reports[report_action].run(r)}.call(current_user)
        end
        send :after_filter, :report_to_innsights, only: :new
      end
    end

    def add_after_filter(klass, action)
      klass.class_eval do
        send :after_filter, :report_to_innsights, only: action.to_sym
      end
    end

    def run(record)
      if Innsights.enabled
        action = Action.new(self, record).as_hash

        case Innsights.queue_system
        when :resque
          Resque.enqueue(RunReport, action)
        when :delayed_job
          Innsights.client.delay.report(action)
        else
          Innsights.client.report(action)
        end
      end
    end

  end
end


