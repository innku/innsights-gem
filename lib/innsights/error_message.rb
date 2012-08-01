module Innsights
  class ErrorMessage
    def self.error_msg(e=Exception.new)
      error_msg_for(default_error_msg,e)
    end

    def self.error_msg_for(msg=nil, e)
      if Innsights.debugging
        "[Innsights Debugging] " << e.message
      else 
        msg || default_error_msg
      end
    end

    def self.default_error_msg
      "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed"
    end
  end
end
