module Innsights
  # Manages the error messages displayed to the user in the default output
  # Also helpful for debugging messages
  #
  # @note for debugging messages to be active. Innsights.debugging should be set to true
  class ErrorMessage
    # Default message for when debugging is set to false or if the user doesn't want to express much with the error
    DEFAULT = "Sorry, we are currently having an error. We are moving to get this fixed"

    # Logs error messages
    # 
    # @param [String, Exception] error the error to be logged
    #   if it's an exception it will logout the message attribute
    # @example
    #   ErrorMessage.log # => [Innsights Error] Sorry, we are currently having an error. We are moving to get this fixed
    #   ErrorMessage.log('Tasty Pie') # => [Innsights Error] Tasty Pie
    #   
    #   ErrorMessage.log(StandardError.new('Tasty Burger')) # => [Innsights Error] Tasty Burger
    def self.log(error="")
      if Innsights.log_errors
        if error.is_a?(Exception)
          message = debug_message(error) 
        elsif !error.empty?
          message = error
        else
          message = DEFAULT
        end
        log_into_rails(message)
        out(message)
      end
    end

    # Returns a debugging message according to the configuration
    # if debugging is enabled, it'll return the exceptions error message, if it's not it will return the DEFAULT_MESSAGE
    #
    # @param [Exception] e the exception
    # @return [String] the exceptions error message or the default error
    def self.debug_message(e)
      return "[Innsights Debugging] " << e.message if Innsights.debugging
      return DEFAULT
    end

    private

    def self.log_into_rails(message)
      if Innsights.rails? && Rails.logger
        Rails.logger.info "[Innsights Debugging ] #{message}"
      end
    end

    def self.out(msg)
      puts "[Innsights Error] #{msg}"
    end

  end
end
