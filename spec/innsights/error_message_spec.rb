require 'spec_helper'

describe Innsights::ErrorMessage do
  describe '.display_error' do
    let(:e){Exception.new}
    context 'When debugging is on' do
      before { Innsights.stub(:debugging).and_return(true) }
      it 'Also prints debugging namespace' do
        Innsights::ErrorMessage.error_msg_for("Error Msg", e).should include "[Innsights Debugging]"
      end
      it 'Prints the e.message' do
        Innsights::ErrorMessage.error_msg_for("Error Msg", e).should include e.message
      end
    end
    context 'When debugging is off' do
      it 'Does not include the debugging namespace' do
        Innsights::ErrorMessage.error_msg_for("Error Msg", e).should_not include "[Innsights Debugging]"
      end
      it 'Only prints the msg' do
        Innsights::ErrorMessage.error_msg_for("Error Msg", e).should include "Error Msg"
      end
      it 'Has a default error message' do
        Innsights::ErrorMessage.error_msg_for(e).should include Innsights::ErrorMessage.default_error_msg
      end
    end

  end
end
