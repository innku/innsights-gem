module Innsights
  class Config::ModelReport < Config::Report
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
  end
end

