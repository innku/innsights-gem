module Innsights
  # DSL to modify the Innsights global configuration of how to get the group id and display
  class Config::Group
        
    # Modifies how to get the group id
    #
    # @param [String, Symbol] value method of how to get the id from the object
    # @example 
    #   Config::Group.id(:id)
    def self.id(value)
      Innsights.group_id = value
    end
    
    # Modifies how to get the group display
    #
    # @param [String, Symbol] value method of how to get the display from the object
    # @example 
    #   Config::Group.display(:name)
    def self.display(value)
      Innsights.group_display = value
    end
    
  end
end