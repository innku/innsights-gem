require 'dummy_app_spec_helper'

describe 'Generic Report' do
  before do 
    Innsights.setup do
      user User do
        display :name
      end
    end
  end

  let(:user) { User.create!}

  it 'Can report a manual action' do
    Innsights.stub_chain(:client, :report)
    Innsights.client.should_receive(:report)
    Innsights.report('Mention', user).run
  end

  it 'Can create a custom create action' do
    User.class_eval do
      after_create :manual_create
      def manual_create
        Innsights.report('Mention', self).run
      end
    end
    Innsights.stub_chain(:client, :report)
    Innsights.client.should_receive(:report)
    User.create!
  end

end
