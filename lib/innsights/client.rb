module Innsights
  class Client
    
    def initialize(url)
      @url = url
      @client = RestClient::Resource.new(@url)
    end
    
    def report(params)
      begin
        @client['/api/actions.json'].post params.to_json, :content_type => :json, :accept => :json
      rescue RestClient::Exception => e
        puts "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed"
      end
    end
    
    def push(file)
      begin
        patient_client['/api/actions/push.json'].post({:file => file})
      rescue RestClient::Exception => e
        puts "[Innsights] Sorry, we are currently having an error. We are moving to get this fixed"
      end
    end
    
    private
    
    def patient_client
      @patient_client ||= RestClient::Resource.new(@url, :timeout => 90000000, :open_timeout => 90000000)
    end
    
  end
end