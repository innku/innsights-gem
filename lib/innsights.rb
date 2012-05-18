require 'rails'
require 'rest_client'
require 'highline/import'
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
  
  mattr_accessor :enabled
  @@enabled = { development: true, test: true, staging:true, production:true }[Rails.env.to_sym]
  
  mattr_accessor :debugging
  @@debugging = false
  
  mattr_accessor :url
  @@url = "sitestest.com"
  
  def self.app_subdomain
    @@app_subdomain ||= credentials["app"]
  end

  def self.app_token
    @@app_token ||= credentials["token"]
  end

  def self.credentials
    @@credentials ||= YAML.load(File.open(File.join(Rails.root, 'config/innsights.yml')))["credentials"]
  end
  
  def self.app_url
    "#{app_subdomain}." << @@url << "/#{Rails.env}"
  end
  
  mattr_accessor :client
  
  def self.setup(&block)
    self.instance_eval(&block)
    self.client = Client.new(url, app_subdomain, app_token, Rails.env)
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