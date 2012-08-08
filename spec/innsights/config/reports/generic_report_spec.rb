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
    context 'Can instanciate' do
      it 'With only the action name as parameter ' do
        r = Innsights::Config::GenericReport.new("Mention")
        r.action_name.should == "Mention"
      end
      it 'With action name and user as parameters ' do
        r = Innsights::Config::GenericReport.new("Mention", user)
        r.action_name.should == "Mention"
        r.report_user.should == user
      end
      it 'With the action name and an option hash as paramets' do
        time = Time.now
        r = Innsights::Config::GenericReport.new("Mention", user: user, created_at: time)
        r.action_name.should == "Mention"
        r.report_user.should == user
        r.created_at.should == time
      end
      it 'Does not modify unspecified options' do
        r = Innsights::Config::GenericReport.new("Mention", created_at: Time.now)
        r.report_user.should == :user
      end
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
