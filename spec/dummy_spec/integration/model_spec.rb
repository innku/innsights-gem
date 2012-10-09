require 'dummy_app_spec_helper'

describe 'Model Report' do
  before do 
    Innsights.setup do
      user Dude do
        display :username
      end
    end
  end

  describe 'Error Handling' do
    it 'Does not crash with a wrong after_callback' do
      Innsights.stub_chain(:client,:report).and_return(true)
      Innsights::ErrorMessage.should_receive(:log)
      lambda{
        Innsights.setup do
          watch Dude do
            upon :alter
          end
        end
      }.should_not raise_error
    end
  end
end
