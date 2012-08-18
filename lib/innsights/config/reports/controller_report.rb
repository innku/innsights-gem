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
      klass = controller_class
      unless klass.nil?
        add_report_to_innsights(klass, @action_name, self, action) 
      end
    end


    def add_report_to_innsights(klass, report_action, report, action)
      if valid_for_report?
        setup_class_for_innsights_report(klass, report_action, report, action)
      else 
        Innsights::ErrorMessage.log
      end
    end

    private

    def setup_class_for_innsights_report(klass, report_action, report, action)
      user = report_user
      klass.class_eval do
        report.simple_class_setup(self, report_action)
        send  :after_filter,
          lambda {|record| 
            begin
              self.innsights_reports[report_action].run(record.send(user)) 
            rescue NoMethodError => e
              Innsights::ErrorMessage.log("#{record} has no method #{user}")
            end
          }, 
          :only => action.to_sym
      end
    end

    # TODO: This is not the right way to require a controller
    def controller_class
      "#{@controller.classify.pluralize}Controller".safe_constantize
    end

    private
    
    def valid_for_report?
      klass = controller_class
      klass.respond_to?(:after_filter) && klass.new.action_methods && !action.nil?
    end
  end
end



