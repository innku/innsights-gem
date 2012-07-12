require 'resque'
require_relative './workers/run_report'

module Innsights
  class Config::Report
    include Helpers::Config

    dsl_attr :event_name,  :upon
    dsl_attr :action_name, :report
    dsl_attr :created_at,  :timestamp
    dsl_attr :report_user, :user

    attr_accessor :klass

    def initialize(klass)
      @klass = klass
      @action_name = klass.name
      @created_at = :created_at
      @event_name = :create
      @report_user = :user
    end

    def commit
      report, action, event = self, @action_name, @event_name
      Innsights.reports << report
      @klass.instance_eval do
        cattr_accessor :innsights_reports unless defined?(@@insights_reports)
        self.innsights_reports ||= {}
        self.innsights_reports[action] = report
        send "after_#{event}", lambda { |record| self.innsights_reports[action].run(record) }
      end
    end

    def run(record)
      puts record.class
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
