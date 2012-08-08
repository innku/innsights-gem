module Innsights
  class Metric
    def initialize(name, value)
      @name = name.to_sym
      @value = value
    end

    def as_array
      [@name, @value]
    end
  end
end
