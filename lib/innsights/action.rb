module Innsights
  class Action
    include Innsights::Helpers::Config

    def initialize(report, record)
      @report = report
      @record = record
      @name   = dsl_attr(report.action_name)
      @created_at = dsl_attr(report.created_at, @record)
      @user = Actions::User.new(@report, @record)
      @group = Actions::Group.new(@user)
    end
    
    def as_hash
      result = {:name => @name, :created_at => @created_at}
      result = result.merge({:user => @user.as_hash}) if @user.valid?
      result = result.merge({:group => @group.as_hash}) if @group.valid?
      {:report => result}
    end
    
  end
end