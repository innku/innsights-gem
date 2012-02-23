require 'spec_helper'

describe Innsights::Config::User do
  let(:klass) { Innsights::Config::User  }
  
  describe '.id' do
    it 'changes innsights user_id' do
      klass.id('to_int')
      Innsights.user_id.should == :to_int
    end
  end
  
  describe '.display' do
    it 'changes innsights user_display' do
      klass.display('to_string')
      Innsights.user_display.should == :to_string
    end
  end
  
end