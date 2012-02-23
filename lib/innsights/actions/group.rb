module Innsights
  class Actions::Group
    
    def initialize(user_action)
      @user_action = user_action
      @user = user_action.object
      @object = @user.send(:try, Innsights.group_call) if Innsights.group_call.present?
    end
    
    def as_hash
      {:app_id => app_id, :display => display}
    end
    
    def valid?
      @user_action.valid? && @object.present?
    end
    
    private
    
    def app_id
      @object.send(:try, Innsights.group_id)
    end
    
    def display
      @object.send(:try, Innsights.group_display)
    end
    
  end
end