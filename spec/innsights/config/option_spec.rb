require 'spec_helper'

describe Innsights::Config::Options do
  describe '.env' do
    before do
      class DummyClass
        include Innsights::Config::Options
      end
    end
    it 'Returns the Rails env when rails is defined' do
      Rails.should_receive(:env){'test'}
      DummyClass.env.should == 'test'
    end
    it 'Returns the Rack env when rails is not defined' do
      ENV['RACK_ENV']= 'new_env'
      DummyClass.stub(:rails?)
      DummyClass.env.should == 'new_env'
    end
  end
end
