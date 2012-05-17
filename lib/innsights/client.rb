module Innsights
  class Client
    
    def initialize(service_url, subdomain, token, env)
      @url = service_url
      @subdomain = subdomain
      @token = token
      @env = env
    end
    
    def report(params)
      begin
        api_client['/api/actions.json'].post *processed_params(params, @token)
      rescue RestClient::Exception => e
        err "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed", e
      end
    end
    
    def push(file)
      begin
        params = {:file => file}
        patient_client['/api/actions/push.json'].post *processed_params(params, @token)
      rescue RestClient::Exception => e
        err "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed", e
      end
    end
    
    ## WWW should not be mandatory on url. Remove when not on dotcloud
    def self.create(app_name)
      begin
        params = {:name => app_name}
        username, password = prompt_credentials
        client = RestClient::Resource.new("www.#{Innsights.url}", username, password)
        response = client['/api/apps.json'].post(params, :content_type => :json, :accept => :json)
        JSON.parse response
      rescue RestClient::Exception => e
        err "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed", e
      end
    end
    
    def self.err(msg, e)
      if Innsights.debugging
        puts "[Innsights Debugging] " << e.message
      else
        puts msg
      end
    end
    
    private
    
    def err(msg, e)
      self.class.err(msg, e)
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
      @patient_client ||= RestClient::Resource.new(api_url,:timeout => 90000000,:open_timeout => 90000000)
    end
    
    def api_url
      @actions_url ||= "#{@subdomain}." << @url << "/#{@env}"
    end
    
  end
end