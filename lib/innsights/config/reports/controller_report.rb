module Innsights
  class Config::ControllerReport < Config::Report

    dsl_attr :event_name,  :catalyst 

    attr_accessor :controller, :action

    def initialize(catalyst)
      super()
      @controller, @action = catalyst.split('#')
      @catalyst = catalyst
    end

    def commit
      report, report_action = self, @action_name
      klass = controller_class
      unless klass.nil?
        Innsights.reports << report
        add_report_to_innsights(klass, report_action, report, action)
      end
    end


    def add_report_to_innsights(klass, report_action, report, action)
      user = report_user
      klass.class_eval do
        if self.respond_to?(:after_filter) && self.new.action_methods && !action.nil?
          cattr_accessor :innsights_reports unless defined?(@@insights_reports)
          self.innsights_reports ||= {}
          self.innsights_reports[report_action] = report
          send  :after_filter,
                lambda {|record| 
                   self.innsights_reports[report_action].run(record.send(user))
                }, 
                :only => action.to_sym
        else 
          puts Innsights::ErrorMessage.error_msg
        end
      end
    end

    private

    def controller_class
      "#{@controller.titleize}Controller".safe_constantize
    end
  end
end



