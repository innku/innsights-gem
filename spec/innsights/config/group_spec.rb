require 'spec_helper'

describe Innsights::Config::Group do
  let(:klass) { Innsights::Config::Group  }
  
  describe '.id' do
    it 'changes innsights group_id' do
      klass.id(10)
      Innsights.group_id.should == 10
    end
  end
  
  describe '.display' do
    it 'changes innsights group_display' do
      klass.display("New thing")
      Innsights.group_display.should == "New thing"
    end
  end
  
end