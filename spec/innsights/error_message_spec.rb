require 'spec_helper'

describe Innsights::ErrorMessage do
  describe '.display_error' do
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
