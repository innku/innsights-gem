module Innsights
  class Config::ModelReport < Config::Report
    def commit
      add_report_to_innsights(@klass, @action_name, self, @event_name)
    end

    def add_report_to_innsights(klass, action, report, event)
      if valid_for_report?
        klass.instance_eval do
          report.simple_class_setup(self, action)
          send "after_#{event}", 
               lambda { |record| self.innsights_reports[action].run(record) }
        end
      else
        puts Innsights::ErrorMessage.error_msg
      end
    end

    private

    def valid_for_report?
      klass.respond_to?("after_#{@event_name}")
    end
  end

end

