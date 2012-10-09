# @attr [Object] object contains the user actor of the app's actions
module Innsights
  class Fetchers::User

    attr_accessor :object
    
    def initialize(object)
      @object = object
    end
    
    # The configured user in a hash format
    #
    # @return [Hash] hash containing user's id and display
    # @example
    #  action_user.to_hash #=> {id: 1, display: "Rogelio Guzman"} 
    def to_hash
      {id: app_id, display: display}
    end
        
    # Value of the configured id attribute of the user object
    #
    # @return  whichever value of the configured id method for the user
    # @example Given a configuration of: Innsights.user_id = :email
    #   action_user.app_id # => "rogelio@innku.com" 
    def app_id
      @object.send(Innsights.user_id)
    end
    
    # Value of the configured display attribute of the user object
    #
    # @return  whichever value of the configured display method for the user
    # @example Given a configuration of: Innsights.user_id = :full_name
    #   action_user.display # => "Rogelio Guzman"
    def display
      @object.send(Innsights.user_display)
    end

    # Value of the configured group display attributes of the user object
    # 
    # @return whichever value of the configured group call for the user
    # @example Given a configuration group value of: Innsights.group_call= :company
    #   action_user.group # => <#Company id=1 name="Innku" ...>
    def group
      @object.send(:try, Innsights.group_call) if Innsights.group_call.present?
    end
    
  end
end
