module Innsights
  # DSL to modify the Innsights global configuration of how to get the user id, display and group
  class Config::User

    # Modifies how to get the user id
    #
    # @param [String, Symbol] value method of how to get the id from the object
    # @example 
    #   Config::User.id(:id)
    def self.id(value)
      Innsights.user_id = value.to_sym
    end

    # Modifies how to get the user display
    #
    # @param [String, Symbol] value method of how to get the display from the object
    # @example 
    #   Config::User.display(:name)
    def self.display(value)
      Innsights.user_display = value.to_sym
    end

    # Modifies how to get the user group object from the user
    #
    # @param [String, Symbol] value method of how to get the group object from the user object
    # @example 
    #   Config::User.group(:company)
    def self.group(value)
      Innsights.group_call = value.to_sym
    end
  end
end