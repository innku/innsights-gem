module Innsights
  class Client
    
    def initialize(url)
      @client = RestClient::Resource.new(url)
    end
    
    def report(params)
      @client['/api/actions.json'].post params.to_json, :content_type => :json, :accept => :json
    end
    
  end
end