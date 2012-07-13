module Innsights
  class Actions::User
    include Helpers::Config
    
    attr_accessor :object
    
    def initialize(report, record)
      @report = report
      @record = record
      if @report.act_on_user == true
        @object = @record
      else
        @object = dsl_attr(@report.report_user, :record => @record)
      end
    end
    
    def as_hash
      {:id => app_id, :display => display } if valid?
    end
    
    def valid?
      @object.present?
    end
    
    private
    
    def app_id
      @object.send(Innsights.user_id)
    end
    
    def display
      @object.send(Innsights.user_display)
    end
    
  end
end
