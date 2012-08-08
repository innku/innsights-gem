require 'dummy_app_spec_helper'

describe 'Generic Report' do
  before do 
    Innsights.setup do
      user Dude do
        display :name
      end
    end
  end

  let(:dude) { Dude.create!}

  it 'Can report a manual action' do
    Innsights.stub_chain(:client, :report)
    Innsights.client.should_receive(:report)
    Innsights.report('Mention', dude).run
  end

  it 'Can create a custom create action' do
    Dude.class_eval do
      after_create :manual_create
      def manual_create
        Innsights.report('Mention', self).run
      end
    end
    Innsights.stub_chain(:client, :report)
    Innsights.client.should_receive(:report)
    Dude.create!
  end

end
