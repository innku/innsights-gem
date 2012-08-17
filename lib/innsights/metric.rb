module Innsights
  class Metric
    include Helpers::Config

    attr_accessor :name, :value

    def initialize(name, value)
      @name = name.to_sym
      @value = value
    end

    def as_array record=nil
      if processed = process_object(record, @value)
        [@name, processed]
      else
        nil
      end
    end
  end
end
