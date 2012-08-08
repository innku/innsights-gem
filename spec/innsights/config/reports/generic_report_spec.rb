require 'spec_helper'

describe Innsights::Config::GenericReport do
  before do 
    class Foo
      def some_method;end;
    end
  end
  let(:user)   { User.create}
  let(:report) { Innsights::Config::GenericReport.new("Mention", user) }
  
  describe '#initialize' do
    it 'Sets the action name' do
      report.action_name.should == "Mention"
    end
    it 'Sets the user' do
      report.report_user.should == user
    end
  end

  describe '.commit' do
    it 'Adds the report to innnsights' do
      Innsights.reports.should_receive(:<<).with(report)
      report.commit
    end
  end
  describe '.run' do
    before do
      Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') 
      Innsights.client.stub(:report).and_return { true }
    end
    context 'With a report user' do
      it 'It users the report_user as the record' do
        Innsights::Action.stub_chain(:new, :as_hash)
        Innsights::Action.should_receive(:new).with(report, user)
        report.run
      end
    end
    context 'Without a report user' do
      it 'Does not run the report' do
        report.report_user = nil
        Innsights::Action.stub_chain(:new, :as_hash)
        Innsights::Action.should_receive(:new).with(report, nil)
        report.run
      end
    end
  end
end
