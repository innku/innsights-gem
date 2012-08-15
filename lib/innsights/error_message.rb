module Innsights
  class ErrorMessage
    
    DEFAULT = "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed"
    
    def self.log(error="")
      if Innsights.log_errors
        return puts(debug_message(error)) if error.is_a?(Exception)
        return puts(error) if !error.empty?
        puts(DEFAULT)
      end
    end
    
    def self.debug_message(e)
      return "[Innsights Debugging] " << e.message if Innsights.debugging
      return DEFAULT
    end
    
  end
end
