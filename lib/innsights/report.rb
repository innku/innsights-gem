module Innsights
  class Report
    
    attr_accessor :event_name, :action_name, :created_at, :report_user, :klass
    
    def initialize(klass_name)
      @klass = eval("Rails::Application::#{klass_name.to_s.classify}")
    end
    
    def upon(event)
      @event_name = event
    end
    
    def report(name)
      @action_name = name
    end
    
    def timestamp(value)
      @created_at = value
    end
    
    def user(user_klass_name)
      @report_user = user_klass_name
    end
        
    def commit
      report, action, event = self, @action_name, @event_name
      @klass.instance_eval do
        cattr_accessor :innsights_reports unless defined?(@@insights_reports)
        self.innsights_reports ||= {}
        self.innsights_reports[action] = report
        send "after_#{event}", lambda { |record| self.innsights_reports[action].run(record) }
      end
    end
    
    def run(record)
      Innsights.client.report(Action.new(self, record).params)
    end
    
  end
end