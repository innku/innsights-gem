module Innsights
  module Config::Options
    def self.included(base)
      base.send :extend, self
    end

    def env
      rails? ? Rails.env : ENV['RACK_ENV']
    end

    def rails?
      defined?(Rails)
    end
  end
end
