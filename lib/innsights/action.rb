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
      if report.metrics
        @metrics = report.metrics.map{|k,v| Metric.new(k,v) } 
      end
    end
    
    def as_hash
      result = {:name => @name }
      result.merge!({:created_at => @created_at}) if @created_at.present?
      result.merge!({:user => @user.as_hash})     if @user.valid?
      result.merge!({:group => @group.as_hash})   if @group.valid?
      result.merge!({:metrics => metrics_hash})   if @metrics.present?
      {:report => result}
    end

    def metrics_hash
      if @metrics.present?
        Hash[@metrics.map{|m| m.as_array(@record)}] 
      end
    end

    
  end
end
