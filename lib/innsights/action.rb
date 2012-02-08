module Innsights
  class Action
    
    def initialize(report, record)
      @report = report
      @record = record
      @name = report.event_name
      @created_at = record.send(report.created_at)
      @user = user
      @group = group
    end
    
    def params
      result = {:name => @name, :created_at => @created_at}
      result = result.merge({:user => @user}) if @user
      result = result.merge({:group => @group}) if @group
      {:report => result}
    end
    
    protected
    
    def user
      if @report.report_user
        @user ||= {:app_id => user_id, :display => user_display}
      end
    end
    
    def group
      if user && Innsights.group_call
        @group ||= {:app_id => group_id, :display => group_display}
      end
    end
    
    def action_user
      @action_user ||= @record.send(@report.report_user)
    end
    
    def action_group
      @action_group ||= action_user.send(Innsights.group_call)
    end
    
    def group_id
      action_group.send(Innsights.group_id)
    end
    
    def group_display
      action_group.send(Innsights.group_display)
    end
    
    def user_id
      action_user.send(Innsights.user_id)
    end
    
    def user_display
      action_user.send(Innsights.user_display)
    end
    
  end
end