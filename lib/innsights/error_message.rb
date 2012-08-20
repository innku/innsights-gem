module Innsights
  class ErrorMessage

    DEFAULT = "Sorry, we are currently having an error. We are moving to get this fixed"

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
