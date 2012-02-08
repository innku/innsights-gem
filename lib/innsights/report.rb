module Innsights
  class Report
    
    attr_accessor :upon, :report, :klass, :user, :timestamp
    
    def initialize(klass_name)
      @klass = eval("Rails::Application::#{klass_name.to_s.classify}")
    end
    
    def upon(event)
      @event_name = event
    end
    
    def report(name)
      @action_name = name
    end
    
    def timestamp(name)
      @timestamp = name
    end
    
    def user(user_klass_name)
      @user = user_klass_name
    end
        
    def commit
      report, action, event = self, @action_name, @event_name
      @klass.instance_eval do
        cattr_accessor :innsights_reports unless defined?(@@insights_reports)
        self.innsights_reports ||= {}
        self.innsights_reports[action] = report
        send "after_#{event}", lambda { self.innsights_reports[action].run }
      end
    end
    
    def run
      ## Code that posts to Innsights app goes here
    end
    
  end
end