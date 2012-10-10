module Innsights
  # Http client class that holds the Service API information
  # 
  # @attr [String] url the url of the service, can be production, staging or development
  # @attr [String] subdomain the subdomain given to your application, by default the apps rails name
  # @attr [String] token the key to posting and getting your information from the service
  # @attr [String] env the environment in which the app is currently reporting, supports development, staging and production
  # @example
  #   client = Innsights::Client.new('innsights.me', 'my_application', 'xxx-my-token', 'development')
  #   client.report({report: {:name: 'New post'}}) # => HTTP Response
  class Client
    
    # Initialization method, sets up all the classes important attributes
    def initialize(service_url, subdomain, token, env)
      @url = service_url
      @subdomain = subdomain
      @token = token
      @env = env
    end
    
    # Posts the given information to the actions service
    # the action service is the main API Service, it receives the action params and creates
    # * Stats graphics
    # * User scoreboards
    # * Group scoreboards
    # @return [String] service API response
    # @example 
    #   client.report({report: {name: 'New post', user: {id: 1, name: 'Adrian'}, group: {id: 2, name: 'Innku'}}})
    #   client.report({report: {name: 'Test actions'}}) # =>  JSON String of the created action
    def report(params)
      safe_app_access do
        api_client['/api/actions.json'].post(*processed_params(params, @token))
      end
    end
    
    # Posts a given file for Innsights to process it in the background
    # generally used for historic information
    # 
    # @param [File] file a file with a json formatted hash of every action to be processed
    # @return [String] HTTP ok
    # @note used in the rake task `rake innsights:push`
    # @example
    #   client.push(json_file)
    def push(file)
      safe_app_access do
        params = {:file => file}
        patient_client['/api/actions/push.json'].post(*processed_params(params, @token))
      end
    end
    
    # Creates an app for your account in Innsights
    # this method will prompt for a username and password
    #
    # @param [String] app_name the application name
    # @return [Hash] hash with the app subdomain and token
    # @note this method is used with the `rails generate innsights:install method`
    # @example
    #   client.create('new_app')
    #   $username: adrian@innku.com
    #   $password: [hidden]
    #   # => {subdomain: [subdomain], token: 'xxx-app-token'}
    def self.create(app_name)
      safe_access do
        params = {:name => app_name}
        username, password = prompt_credentials
        client = RestClient::Resource.new(Innsights.url, username, password)
        response = client['/api/apps.json'].post(params, :content_type => :json, :accept => :json)
        JSON.parse(response)
      end
    end
    
    private
    
    def safe_app_access(&block)
      begin
        yield
      rescue RestClient::Unauthorized => e
        Innsights::ErrorMessage.log('Check your credentials. You do not have access to this app.')
      rescue RestClient::Exception => e
        Innsights::ErrorMessage.log(e)
      end
    end
    
    def self.safe_access(&block)
      begin
        yield
      rescue RestClient::Unauthorized => e
        Innsights::ErrorMessage.log("Wrong username or password.")
      rescue RestClient::Exception => e
        Innsights::ErrorMessage.log(e)
      end
    end
    
    def self.prompt_credentials
      [ask("Username: "), ask("Password: "){|q| q.echo = false}]
    end
    
    def processed_params(params, token)
      params = params.merge({:authenticity_token => token})
      [params, {:content_type => :json, :accept => :json}]
    end
    
    def api_client
      @actions_client ||= RestClient::Resource.new(api_url)
    end
    
    def patient_client
      @patient_client ||= RestClient::Resource.new(api_url, :timeout => nil)
    end
    
    def api_url
      @actions_url ||= "#{@subdomain}." << @url << "/#{@env}"
    end
    
  end
end
