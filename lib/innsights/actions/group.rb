module Innsights
  class Actions::Group
    include Helpers::Config
    
    def initialize(param, options={})
      if param.is_a?(Innsights::Actions::User)
        setup_from_user(param)
      elsif options[:method].present?
        @object = process_object(param, options[:method])
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

    def setup_from_user(user)
      @user_action = user
      @user = user.object
      @object = @user.send(:try, Innsights.group_call) if Innsights.group_call.present?
    end
    
    def app_id
      @object.send(:try, Innsights.group_id)
    end
    
    def display
      @object.send(:try, Innsights.group_display)
    end
    
  end
end
