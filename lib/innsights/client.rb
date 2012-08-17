module Innsights
  class Client
    
    def initialize(service_url, subdomain, token, env)
      @url = service_url
      @subdomain = subdomain
      @token = token
      @env = env
    end
    
    def report(params)
      safe_app_access do
        api_client['/api/actions.json'].post(*processed_params(params, @token))
      end
    end
    
    def push(file)
      safe_app_access do
        params = {:file => file}
        patient_client['/api/actions/push.json'].post(*processed_params(params, @token))
      end
    end
    
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
