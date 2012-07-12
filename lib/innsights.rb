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
    autoload :CustomReport, 'innsights/config/custom_report'
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
  
  mattr_accessor :client
  
  mattr_accessor :queue_system
  @@queue_system = nil
  @@supported_queue_systems = [:delayed_job, :resque]

  # Configured subdomain of the client app
  # @return [String] subdomain of current app
  def self.app_subdomain
    @@app_subdomain ||= credentials["app"]
  end
  
  # Configured token of client app
  # @return [String] authentication token of app
  def self.app_token
    @@app_token ||= credentials["token"]
  end

  # Configuration variables of client app
  # @return [Hash] containing the subdomain and authentication token of app
  def self.credentials
    @@credentials ||= YAML.load(File.open(File.join(Rails.root, 'config/innsights.yml')))["credentials"]
  end
  
  # Final url to post actions to, includes the rails app environment
  # @return [String] contains app subdomain, innsights url and client app environment
  def self.app_url
    "#{app_subdomain}." << @@url << "/#{Rails.env}"
  end
  
  # Sets testing environment on for local server development
  # @param [true,false] on testing on or off
  # @return [String] with local server url if on, nil if off
  mattr_reader :test_mode
  def self.test_mode=(on)
    @@test_mode = on
    @@url = 'innsights.dev' if on
  end
  
  # Main configuration method to create all event watchers
  # @yield Configuration for
  #   * App user class
  #   * Appp action reports
  def self.setup(&block)
    self.instance_eval(&block)
    self.client = Client.new(url, app_subdomain, app_token, Rails.env)
  end

  # Extra configuration for custom experience
  # @yield Configuration for
  #   * Queue system
  #   * Test mode
  def self.config(*envs, &block)
    self.instance_eval(&block) if envs.blank?
    envs.each do |env| 
      self.instance_eval(&block) if Rails.env == env.to_s
    end
  end
  
  # Sets up the user class and configures the display and group
  # @yield Configuration for
  #   * display
  #   * id
  #   * group
  def self.user(klass, &block)
    self.user_call = klass.to_s.downcase.to_sym
    Config::User.class_eval(&block) if block_given? 
  end

  # Sets up an event observer for creating an action on Innsights
  # @yield Configuration for
  #   * Action Name
  #   * Timestamp
  #   * User call
  #   * Event Trigger
  def self.watch(klass, params={}, &block)
    report = Config::Report.new(params[:class] || klass)
    report.instance_eval(&block)
    report.commit
  end

  # Sets up an event observer for creating an custom action on Innsights
  # @yield Configuration for
  #   * Action Name
  #   * Timestamp
  #   * User call
  #   * Event Trigger
  def self.on(catalyst, &block)
    report = Config::CustomReport.new(catalyst)
    report.instance_eval(&block)
    report.commit
  end
  # Sets up the user class and configures the display and group
  # @param [:resque, :delayed_job]
  def self.queue(queue='')
	self.queue_system = queue if @@supported_queue_systems.include?(queue)
  end

  def self.test(test_mode='')
    self.test_mode = test_mode
  end
  
  
  if defined?(Rails)
    require 'innsights/railtie'
  end
    
end
