require 'spec_helper'

describe Innsights::Client do
  before { Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') }

  let(:client) { Innsights.client }
  let(:params) do
    {:report => {:name => "Post", :created_at => '2012-02-23 08:11:00 -0600',
                 :user =>  {:app_id => 1, :display => 'Adrian'},
                 :group => {:app_id => 1, :display => 'Innku'},
                 :source => 'tumblr' }}
  end
  let(:file) { json_fixture('test_upload.json') }
  
  describe '#report' do
    it 'should do nothing when the response is successful' do
      VCR.use_cassette('ok_response', :record => :new_episodes) do
        lambda { Innsights.client.report(params) }.should_not raise_error
      end
    end
    it 'should do nothing when the response is 404' do
      VCR.use_cassette('404_response', :record => :new_episodes) do
        lambda { Innsights.client.report(params) }.should_not raise_error
      end
    end
    it 'should do nothing when the response is 500' do
      VCR.use_cassette('500_response', :record => :new_episodes) do
        lambda { Innsights.client.report(params) }.should_not raise_error
      end
    end
  end
  
  describe '#push' do
    it 'should do nothing when the response is successful' do
      VCR.use_cassette('push_ok_response', :record => :new_episodes) do
        lambda { Innsights.client.push(file) }.should_not raise_error
      end
    end
    it 'should do nothing when the response is 404' do
      VCR.use_cassette('push_404_response', :record => :new_episodes) do
        lambda { Innsights.client.push(file) }.should_not raise_error
      end
    end
    it 'should do nothing when the response is 500' do
      VCR.use_cassette('push_500_response', :record => :new_episodes) do
        lambda { Innsights.client.push(file) }.should_not raise_error
      end
    end
  end
  
end
