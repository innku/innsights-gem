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
    it 'Can instantiate the action name' do
      r = Innsights::Config::GenericReport.new("Mention")
      r.action_name.should == "Mention"
    end
    it 'Can instantiate with action name and user' do
      r = Innsights::Config::GenericReport.new("Mention", user)
      r.action_name.should == "Mention"
      r.report_user.should == user
    end
    it 'Can instantiate action name and an option hash' do
      time = Time.now
      r = Innsights::Config::GenericReport.new("Mention", user: user, created_at: time)
      r.action_name.should == "Mention"
      r.report_user.should == user
      r.created_at.should == time
    end
    it 'Can add a group' do
      company = Company.new
      r = Innsights::Config::GenericReport.new("Mention", group: company)
      r.report_group.should == company
    end
    it 'Can add a created_at' do
      time = Time.now
      r = Innsights::Config::GenericReport.new("Mention", created_at: time)
      r.created_at.should == time
    end
    it 'Can add a single metic' do
      r = Innsights::Config::GenericReport.new("Mention", measure: {kg: 100})
      r.metrics.should == {kg: 100}
    end
    it 'Can add multiple metrics' do
      r = Innsights::Config::GenericReport.new("Mention", measure: {kg: 100, money: 200})
      r.metrics.should == {kg: 100, money: 200}
    end
    it 'Does not modify unspecified options' do
      r = Innsights::Config::GenericReport.new("Mention", created_at: Time.now)
      r.report_user.should == :user
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
          Innsights::Action.should_receive(:new).with(report, nil)
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
