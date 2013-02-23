module Innsights
  # Stores the group object and fetches the important parts for the API Service
  # @attr [Object] object contains the group object the user belongs to
  class Fetchers::Group
    attr_accessor :object, :resource_group
    
    # Sets the group object as the instance variable
    # @param [Object] object the group object
    def initialize(object, resource_group)
      @object = object
      @resource_group = resource_group
    end
    
    # The configured group in a hash format
    #
    # @return [Hash] hash containing group's id and display
    # @example
    #  action_group.to_hash #=> {id: 1, display: "Innku"} 
    def to_hash
      { resource_group.to_sym =>  {:id => app_id, :display => display}}
    end
    
    # Value of the configured id attribute of the group object
    #
    # @return  whichever value of the configured id method for the group
    # @example Given a configuration of: Innsights.group_id = :id
    #   action_group.app_id # => 1
    def app_id
      object.send(:try, Innsights.group_id)
    end
    
    # Value of the configured id attribute of the group object
    #
    # @return  whichever value of the configured id method for the group
    # @example Given a configuration of: Innsights.group_display = :name
    #   action_group.display # => "Innku"
    def display
      object.send(:try, Innsights.group_display)
    end
    
  end
end
