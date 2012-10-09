# @param [String] catalyst the catalyst formated as 'controller#action'
# @param [String] controller_name the first part of the catalyst, the controller name without the word 'controller'
# @param [String] action_name the action of the controller that will be injected with the after_filter
module Innsights
  module Config
    class Controller < Config::Base
      attr_accessor :controller_name, :action_name, :catalyst

      def initialize(catalyst)
        @catalyst = catalyst
        @controller_name, @action_name = catalyst.split('#')
        @name = [action_name.to_s, controller_name.to_s].join(" ")
        @metrics = {}
      end

      # Records the configuration of the report into the controller and readies it with an after_filter
      # this method will not work unless the controller class actually responds to after_filter
      #
      # @return [Class] controller class with the after_filter method embedded in it
      def commit
        if valid?
          callback_process = setup(controller)
          controller.after_filter callback_process, :only => action_name
          controller
        else
          Innsights::ErrorMessage.log("#{controller_name} class has no valid method #{action_name}")
        end
      end

      # Controller to inject the after filter into
      #
      # @return [Class] controller class
      def controller
        (controller_name.classify.pluralize << "Controller").constantize
      end
      
      # Is the controller method valid to inject an after_filter?
      #
      # @return [Boolean] true if valid, false if invalid
      def valid?
        controller.respond_to?(:after_filter) && controller.new.action_methods.include?(action_name)
      end

    end
  end
end