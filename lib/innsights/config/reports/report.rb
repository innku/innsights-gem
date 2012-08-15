require 'resque'
require_relative './../workers/run_report'

module Innsights
  class Config::Report
    include Helpers::Config

    dsl_attr :event_name,  :upon
    dsl_attr :action_name, :report
    dsl_attr :created_at,  :timestamp
    dsl_attr :report_user, :user
    dsl_attr :report_group, :group
    
    attr_accessor :klass, :metrics

    def initialize(klass=nil)
      @created_at = :created_at
      @event_name = :create
      @report_user = :user
      @metrics = {}
      unless klass.nil?
        @klass = klass
        @action_name = klass.name
      end
    end

    def run(record=nil)
      if Innsights.enabled?
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
    
    def measure(measure, with=nil)
      with ||= {with: measure}
      metrics.merge!({measure.to_sym => with[:with]})
    end

    def simple_class_setup(klass, report_action)
      Innsights.reports << self
      klass.cattr_accessor :innsights_reports unless defined?(@@insights_reports)
      klass.innsights_reports ||= {}
      klass.innsights_reports[report_action] = self
    end

    def valid_for_push?
      false
    end
  end
end
