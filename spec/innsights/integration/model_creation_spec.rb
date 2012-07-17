require 'spec_helper'

describe 'User Model Report' do
  before do 
    Innsights.test_mode= true
    Innsights.stub(:credentials){{app: 'tweet', token: 1233}}
    Innsights::Config::ModelReport.any_instance.stub(:run){true}
    Innsights.setup do
      user :User do
      end
      watch User do
        report :chino
      end
    end
  end
  it 'Fails' do
    User.create
  end
end

