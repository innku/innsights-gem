module Innsights
  # Module that helps build a DSL Around a given class and to consume the values of the user input
  module Helpers::Config
    
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      # Creates a local variable that saves either a string or block
      # eases the process of defining attribute values through DSL
      #
      # @attr [Symbol, String] method name the name of the dsl method to be defined
      # @attr [Symbol, String] instance_var_name the name of the instance variable that stores the result of the method call
      # @example
      #   class Man
      #     dsl :walk, :meters
      #     walk {|record| record.km * 1000 } # => Man
      #     walk :meters # => Man
      #   end
      def dsl(method_name, instance_var_name)
        attr_accessor instance_var_name
        define_method method_name do |value=nil, &block|
          instance_var_value = block.nil? ? value : block
          instance_variable_set("@#{instance_var_name}", instance_var_value)
          self
        end
      end
    end
    
    module InstanceMethods
      # Calls the given method of the record or yields the given proc with the record.
      #
      # @param [Object] record the record that holds the information
      # @param [Symbol, Proc, Object] strat
      #   when Symbol it is the name of the method to call
      #   when Proc it is a process to yield with the record as a param
      #   when Object it is the primitive value of to be sent as the attribute
      # @example
      #   user = User.new(name: 'Adrian', email: 'adrian@innku.com')
      #   attr_call(user, :name) # => 'Adrian'
      #   attr_call(user, lambda {|u| u.email }) # => 'adrian@innku.com'
      #   attr_call(user, 100) # 100
      #   attr_call(user, "Some name") # => "Some name"
      def dsl_call(record, strat)
        if strat.is_a?(Symbol)
          begin
            return record.send(:try, strat)
          rescue NoMethodError
            nil # Fail silently if the method doesn't exist
          end
        elsif strat.is_a?(Proc)
          begin
            return strat.call(record)
          rescue
            nil # Fail silently on runtime
          end
        else
          return strat
        end
      end
    end

  end
end
