require 'rails'
require 'rest_client'
require "innsights/version"

module Innsights
  
  module Helpers
    autoload :Tasks,          'innsights/helpers/tasks'
    autoload :Config,         'innsights/helpers/config'
  end
  
  module Actions
    autoload :User,   'innsights/actions/user'
    autoload :Group,  'innsights/actions/group'
  end
  
  module Config
    autoload :Report,       'innsights/config/report'
    autoload :User,         'innsights/config/user'
    autoload :Group,        'innsights/config/group'
  end
  
  autoload :Action,       'innsights/action'
  autoload :Client,       'innsights/client'

  ## Configuration defaults
  mattr_accessor :user_call
  @@user_call = :user
  
  mattr_accessor :user_id
  @@user_id = :id
  
  mattr_accessor :user_display
  @@user_display = :to_s
  
  mattr_accessor :group_call
  @@group_call = nil
  
  mattr_accessor :group_id
  @@group_id = :id
  
  mattr_accessor :group_display
  @@group_display = :to_s
  
  mattr_accessor :reports
  @@reports = []
  
  @@url = { :development => 'http://127.0.0.1:5000',
            :test => 'http://127.0.0.1:5000',
            :staging => 'innsights.herokuapp.com',
            :production => 'innsights.herokuapp.com'}[Rails.env.to_sym]
    
  mattr_accessor :client
  @@client = Client.new(@@url)
  
  def self.setup(&block)
    self.instance_eval(&block)
  end
  
  def self.user(call=:user, &block)
    self.user_call = call.to_sym
    Config::User.class_eval(&block) if block_given? 
  end
  
  def self.watch(klass, params={}, &block)
    report = Config::Report.new(params[:class] || klass)
    report.instance_eval(&block)
    report.commit
  end
  
  if defined?(Rails)
    require 'innsights/railtie'
  end
    
end