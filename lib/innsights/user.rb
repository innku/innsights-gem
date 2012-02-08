module Innsights
  class User
    
    def self.id(value)
      Innsights.user_id = value.to_sym
    end
    
    def self.display(value)
      Innsights.user_display = value.to_sym
    end
    
    def self.group(value, &block)
      Innsights.group_call = value.to_sym
      Group.class_eval(&block)
    end
    
  end
end