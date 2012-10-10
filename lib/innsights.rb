require 'active_support/core_ext'
require 'rest_client'
require 'highline/import'
require "innsights/version"

module Innsights
  
  # Helper modules for DSL configuration and rake tasks
  module Helpers
    autoload :Tasks,            'innsights/helpers/tasks'
    autoload :Config,           'innsights/helpers/config'
  end
  
  # Classes that hold record, user and group instances and apply the global configuration
  # to get the information needed for the report
  module Fetchers
    autoload :User,             'innsights/fetchers/user'
    autoload :Group,            'innsights/fetchers/group'
    autoload :Record,           'innsights/fetchers/record'
  end
  
  # Classes that hold global configuration for:
  # * Reports
  # * User information
  # * Group information
  module Config
    autoload :Base,             'innsights/config/base'
    autoload :Controller,       'innsights/config/controller'
    autoload :Model,            'innsights/config/model'
    autoload :User,             'innsights/config/user'
    autoload :Group,            'innsights/config/group'
  end

  # Resque Job for background action reporting
  module Jobs
    autoload :RunReport,        'innsights/jobs/run_report'
  end

  autoload :Report,             'innsights/report'
  autoload :ErrorMessage,       'innsights/error_message'
  autoload :Client,             'innsights/client'

  mattr_accessor :client

  mattr_accessor :debugging
  @@debugging = false

  mattr_accessor :enable_hash
  @@enable_hash = { development: true, test: true, staging:true, production:true }

  mattr_accessor :env_scope

  mattr_accessor :group_call
  @@group_call = nil

  mattr_accessor :group_class
  @@group_class = :group
  
  mattr_accessor :group_id
  @@group_id = :id
  
  mattr_accessor :group_display
  @@group_display = :to_s

  mattr_accessor :group_id
  @@group_id = :id

  mattr_accessor :queue_system
  @@queue_system = nil

  mattr_accessor :reports
  @@reports = []
  
  mattr_accessor :test_url
  @@test_url = "innsights.dev"

  mattr_accessor :url
  @@url = "innsights.me"

  mattr_accessor :user_call
  @@user_call = :user
  
  mattr_accessor :test_url
  @@test_url = "innsights.dev"
  
  mattr_accessor :staging_url
  @@staging_url = "innsights.info"
  
  mattr_accessor :log_errors
  @@log_errors = true
  
  mattr_accessor :client

  mattr_accessor :user_id
  @@user_id = :id
  
  mattr_accessor :user_display
  @@user_display = :to_s

  mattr_accessor :user_env
  
  @@supported_queue_systems = [:delayed_job, :resque]

  # Configured subdomain of the client app
  # @return [String] subdomain of current app
  def self.app_subdomain
    @@app_subdomain ||= credentials[:app]
  end
  
  # Configured token of client app
  # @return [String] authentication token of app
  def self.app_token
    @@app_token ||= credentials[:token]
  end

  # Configuration variables of client app
  #
  # @param [Hash] cred hash of credentials containing both subdmain and token
  # @return [Hash] containing the subdomain and authentication token of app
  # @example
  #   Innsights.credentials {"token": 'xxx-token', subdomain: 'my_app'} # => {token: 'xxx-token', subdomain: 'my_app'}
  #   Innsights.credentials # => {token: 'xxx-token', subdomain: 'my_app'}
  def self.credentials(cred=nil)
    if cred.is_a? Hash
      @@credentials = cred.symbolize_keys
    elsif rails?
      @@credentials ||= credentials_from_yaml
    else
      @@credentials 
    end
  end

  
  # Final url to post actions to, includes the rails app environment
  # @return [String] contains app subdomain, innsights url and client app environment
  def self.app_url
    "#{app_subdomain}." << @@url << "/#{self.current_env}"
  end
  
  # Sets testing environment on for local server development
  # @param [true,false] on testing on or off
  # @return [String] with local server url if on, nil if off
  # @example 
  #   Innsights.mode :test # => innsights.dev
  mattr_reader :test_mode
  def self.mode(mode)
    if mode == :staging || mode == :test
      @@test_mode = true
      @@url = self.send("#{mode}_url")
    end
  end
  
  # Main configuration method to create all event watchers
  # @yield Configuration for
  #   * App user class
  #   * Appp action reports
  # @example
  #   Innsights.setup do
  #     watch Post do
  #       report 'New Post'
  #     end
  #   end
  def self.setup(&block)
    self.instance_eval(&block)
    self.client = Client.new(url, app_subdomain, app_token, self.current_env)
  end

  # Extra configuration for custom experience
  # 
  # @deprecated Configure specific behaviour on config/innsights.yml instead
  # @yield Configuration for
  #   * Queue system
  #   * Test mode
  def self.config(*envs, &block)
    self.instance_eval(&block) if envs.blank?
    envs.each do |env| 
      @@env_scope = env
      self.instance_eval(&block) if self.current_env == env.to_s
      @@env_scope = nil
    end
  end

  
  # Sets up the user class and configures the id, display and group
  # @yield Configuration for
  #   * display
  #   * id
  #   * group
  # @example 
  #   Innsights.user do
  #     id :id
  #     display :name
  #     group :company
  #   end
  def self.user(klass, &block)
    self.user_call = klass.to_s.downcase.to_sym
    Config::User.class_eval(&block) if block_given? 
  end

  # Sets up the group class and configures the display and id
  # @yield Configuration for
  #   * display
  #   * id
  # @example 
  #   Innsights.group do
  #     id :id
  #     display :corp
  #   end
  def self.group(klass, &block)
    self.group_class = klass.to_s.underscore.to_sym
    Config::Group.class_eval(&block) if block_given? 
  end

  # Sets up and active record callback for models or an after filter for controllers
  #
  # @yield Configuration for
  #   * Action Name
  #   * Timestamp
  #   * User call
  #   * Event Trigger
  # @example
  #   # Configure callback for models
  #   Innsights.watch Order do
  #     report 'Purchase'
  #     event :after_create
  #     user  :buyer
  #   end
  #   # Configure callback for controllers
  #   Innsights.watch 'account#prices' do
  #     report 'Upgrade Intention'
  #     user   :current_user
  #   end
  def self.watch(instance, &block)
    report = instance.is_a?(String) ? Config::Controller.new(instance) : Config::Model.new(instance)
    report.instance_eval(&block)
    report.commit
  end

  # Sets up an event observer for creating an custom action on Innsights
  # @yield Configuration for
  #   * Action Name
  #   * Timestamp
  #   * User call
  #   * Event Trigger
  # @deprecated User #{watch} instead
  def self.on(catalyst, &block)
    report = Config::Controller.new(catalyst)
    report.instance_eval(&block)
    report.commit
  end

  # Sets up the queue library used to report actions to Innsights
  #
  # @param [String, Symbol] queue libraries available are :resque, and :delayed_job
  def self.queue(queue='')
    if @@supported_queue_systems.include?(queue)
      self.queue_system = queue 
    end
  end
  
  # Creates a report on the fly. Can be used from within any file
  #
  # @param [String] name is the name of the action to be reported
  # @return [Innsights::Report] the report instance ready to run
  def self.report(name, options={})
    Innsights::Report.new(name, options)
  end

  # Enables or disables reporting with client
  # 
  # @param [String, Symbol] env the environment in which the enabling/disabling will take action
  # @param [Boolean] value true if enabled, false if disabled
  # @todo clean this mess up when self.config goes away
  def self.enable(env=nil, value)
    env ||= @@env_scope
    if env.present?
      @@enable_hash[env.to_sym] = value 
    else
      @@enable_hash.each do |env, v|
        @@enable_hash[env.to_sym] = value
      end
    end
  end

  # Answers if the current environment is enabled or not
  # @todo should not be using a hash. config messed up with this implementation
  def self.enabled?
    @@enable_hash[self.current_env.to_sym] == true
  end

  # Sets the environment.
  #
  # @note The user set environment holds priority over all others
  # @param [String] env environment set by user
  def self.environment env
    self.user_env = env
  end

  # Current app environment. The order of priority is:
  # * User set environment
  # * Rails
  # * RACK_ENV environment variable
  def self.current_env
    return self.user_env if self.user_env
    return Rails.env if rails?
    return ENV['RACK_ENV']
  end

  # True if Rails is defined in the contect
  def self.rails?
    defined?(Rails)
  end

  # Require railtie only if Rails is defined
  require 'innsights/railtie' if rails?

  private 

  def self.credentials_from_yaml
    YAML.load(File.open(File.join(Rails.root, 'config/innsights.yml')))["credentials"].symbolize_keys
  end

end
