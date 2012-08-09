module Innsights
  class Metric
    attr_accessor :name, :value

    def initialize(name, value)
      @name = name.to_sym
      @value = value
    end

    def as_array_for_user user
      [@name, process_value_for_user(user)]
    end

    def process_value_for_user user
      if value.is_a?(Fixnum)
        value
      elsif value.is_a?(Proc)
        value.call user rescue nil
      elsif value.is_a?(String) || value.is_a?(Symbol)
        begin
          user.send(value.to_sym) 
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
