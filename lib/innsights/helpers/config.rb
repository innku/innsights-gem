module Innsights
  module Helpers::Config
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      ## Creates a local variable that saves either a string or block
      def dsl_attr(instance_var_name, method_name)
        attr_accessor instance_var_name
        define_method method_name do |value=nil, &block|
          instance_var_value = block.nil? ? value : block
          instance_variable_set("@#{instance_var_name}", instance_var_value)
        end
      end
    end
    
    module InstanceMethods
      def dsl_attr(strat, record=nil)
        if strat.is_a?(String) || strat.is_a?(Symbol)
          return strat if record.nil?
          return record.send(:try, strat)
        elsif strat.is_a?(Proc)
          return strat.call(record)
        end
      end
    end
        
  end
end