require 'dummy_app_spec_helper'

describe 'Model Report' do
  before do 
    Innsights.setup do
      user User do
        display :username
      end
    end
  end

  describe 'Error Handling' do
    it 'Does not crash with a wrong after_callback' do
      Innsights::ErrorMessage.should_receive(:error_msg)
      lambda{
        Innsights.setup do
          watch User do
            upon :alter
          end
        end
      }.should_not raise_error
    end
  end
end
