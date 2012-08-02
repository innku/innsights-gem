module Innsights
  class Config::ModelReport < Config::Report
    def commit
      add_report_to_innsights(@klass, @action_name, self, @event_name)
    end

    def add_report_to_innsights(klass, action, report, event)
      klass.instance_eval do
        report.simple_class_setup(self, action, report)
        send "after_#{event}", lambda { |record| self.innsights_reports[action].run(record) }
      end
    end
  end

end

