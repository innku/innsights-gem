module Innsights
  class ErrorMessage
    
    DEFAULT = "Sorry, we are currently having an error. We are moving to get this fixed"
    
    def self.log(error="")
      if Innsights.log_errors
        return out(debug_message(error)) if error.is_a?(Exception)
        return out(error) if !error.empty?
        out(DEFAULT)
      end
    end
    
    def self.debug_message(e)
      return "[Innsights Debugging] " << e.message if Innsights.debugging
      return DEFAULT
    end
    
    private
    
    def self.out(msg)
      puts "[Innsights Error] #{msg}"
    end
    
  end
end
