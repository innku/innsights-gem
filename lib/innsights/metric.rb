module Innsights
  class Metric
    attr_accessor :name, :value

    def initialize(name, value)
      @name = name.to_sym
      @value = value
    end

    def as_array record=nil
      if processed = process_value(record)
        [@name, processed]
      else
        nil
      end
    end

    def process_value record=nil
      if value.is_a?(Fixnum)
        value
      elsif value.is_a?(Proc)
        value.call record rescue nil
      elsif value.is_a?(String) || value.is_a?(Symbol)
        begin
          record.send(value.to_sym) 
        rescue NoMethodError
          nil
        end
      end
    end

  end
end
