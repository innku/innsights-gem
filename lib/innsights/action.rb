module Innsights
  class Action
    include Innsights::Helpers::Config

    def initialize(report, record)
      @report = report
      @record = record
      @name   = dsl_attr(report.action_name, :record => @record, :is_method => false)
      @created_at = dsl_attr(report.created_at, :record => @record)
      @user = Actions::User.new(@report, @record)
      @group = Actions::Group.new(@user)
    end
    
    def as_hash
      result = {:name => @name }
      result = result.merge({:created_at => @created_at}) if @created_at.present?
      result = result.merge({:user => @user.as_hash}) if @user.valid?
      result = result.merge({:group => @group.as_hash}) if @group.valid?
      {:report => result}
    end
    
  end
end
