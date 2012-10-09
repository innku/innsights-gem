require 'spec_helper'

describe Innsights::Config::Model do
  before do 
    class TestApp; end
    TestApp.stub!(:after_create)
  end
  let(:report) { Innsights::Config::Model.new(TestApp) }
  
  describe '#commit' do    
    it 'adds the report to applications reports array' do
      report.commit
      Innsights.reports.should include(report)
    end
    it 'defines innsights_reports for the reported class' do
      report.commit
      report.klass.should respond_to(:innsights_reports)
    end
    it 'associates event name with report object' do
      report.commit
      TestApp.innsights_reports[report.name].should == report
    end
    it 'send a block to after_create on the report klass' do
      report.klass.should_receive(:after_create)
      report.commit
    end
  end

  describe '#report' do
    context 'When there is a condition' do
      it 'sets the event name' do
        report.report :something
        report.name.should == :something
      end

      it 'Set the condition' do
        condition = lambda {|r| true }
        report.report :something, if: condition
        report.instance_variable_get("@condition").should == condition
      end
    end
    context 'When there is no condition' do
      it 'sets the event name' do
        report.report :something
        report.name.should == :something
      end

      it 'Does not set the condition' do
        report.report :something
        report.instance_variable_get("@condition").should == nil
      end
    end
  end

  describe '.valid_for_push?' do
    it 'Returns false if not valid' do
      report.event = :after_upload
      report.valid_for_push?.should == false
    end

    it 'Returns true if valid' do
      report.event = :after_create
      report.valid_for_push?.should == true
    end
  end
end
