require 'spec_helper'

describe Innsights::ErrorMessage do
  describe '.log' do
    before do 
      Innsights.stub!(:log_errors){true}
      Rails.stub!(:logger){ false }
    end
    it 'Outputs the debug_message when there is an exception' do
      e = Exception.new
      Innsights::ErrorMessage.should_receive(:debug_message).with(e)
      Innsights::ErrorMessage.should_receive(:out)
      Innsights::ErrorMessage.log(e)
    end
    it 'Outputs the error When it is not an exception' do
      e = "some error"
      Innsights::ErrorMessage.should_receive(:out).with(e)
      Innsights::ErrorMessage.log(e)
    end
    it 'Outputs the default message as the default option' do
      default = Innsights::ErrorMessage::DEFAULT
      Innsights::ErrorMessage.should_receive(:out).with(default)
      Innsights::ErrorMessage.log
    end
    describe 'Rails logger' do
      context 'When Rails is defined and the logger exists' do
        before do 
          Innsights.stub!(:rails){true}
          Rails.stub!(:logger){true}
        end
        it 'Logs the error' do
          Rails.stub_chain(:logger, :info)
          Rails.logger.should_receive(:info)
          Innsights::ErrorMessage.log
        end
      end
      context 'When Rails is not defined or the logger does not exist' do
        before do 
          Innsights.stub!(:rails){false}
          Rails.stub!(:logger){false}
        end
        it 'Logs the error' do
          Rails.stub_chain(:logger, :info)
          Rails.logger.should_not_receive(:info)
          Innsights::ErrorMessage.log
        end
      end
    end
  end
  describe '.debug_message' do
    let(:e) { Exception.new('Error Msg') }
    context 'When debugging is on' do
      before { Innsights.stub(:debugging).and_return(true) }
      it 'Also prints debugging namespace' do
        Innsights::ErrorMessage.debug_message(e).should include "[Innsights Debugging]"
      end
      it 'Prints the e.message' do
        Innsights::ErrorMessage.debug_message(e).should include e.message
      end
    end
    context 'When debugging is off' do
      before { Innsights.stub(:debugging).and_return(false) }
      it 'Does not include the debugging namespace' do
        Innsights::ErrorMessage.debug_message(e).should_not include "[Innsights Debugging]"
      end
      it 'Has a default error message' do
        Innsights::ErrorMessage.debug_message(e).should include Innsights::ErrorMessage::DEFAULT
      end
    end

  end
end
