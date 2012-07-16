require 'spec_helper'
require 'delayed_job_active_record'

describe Innsights::Config::ModelReport do
  before do 
    class TestApp; end
    TestApp.stub!(:after_create)
  end
  let(:report) { Innsights::Config::ModelReport.new(TestApp) }
  
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
      TestApp.innsights_reports[report.action_name].should == report
    end
    it 'send a block to after_create on the report klass' do
      report.klass.should_receive(:after_create)
      report.commit
    end
  end
end
