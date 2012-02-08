require 'rails'
require "innsights/version"

module Innsights
  
  autoload :Report, 'innsights/report'
  autoload :User, 'innsights/user'
  autoload :Group, 'innsights/group'
  
  mattr_accessor :user_call,  :user_id, :user_display, 
                 :group_call, :group_id, :group_display
  
  def self.setup(&block)
    self.instance_eval(&block)
  end
  
  def self.user(call=:user, &block)
    self.user_call = call.to_sym
    User.class_eval(&block)
  end
  
  def self.watch(klass_name, params={}, &block)
    report = Report.new(params[:class] || klass_name)
    report.instance_eval(&block)
    report.commit
  end
  
end