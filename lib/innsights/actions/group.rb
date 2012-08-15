module Innsights
  class Actions::Group
    
    def initialize(param, options={})
      if param.is_a?(Innsights::Actions::User)
        @user_action = param
        @user = param.object
        @object = @user.send(:try, Innsights.group_call) if Innsights.group_call.present?
      elsif options[:method].present?
        @object = param.send(:try, options[:method]) 
      else
        @object = param
      end
    end
    
    def as_hash
      {:id => app_id, :display => display}
    end
    
    def valid?
      if @user_action.present?
        @user_action.valid? && @object.present?
      else
        @object.present?
      end
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
