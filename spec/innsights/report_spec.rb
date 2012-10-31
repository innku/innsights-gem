require 'spec_helper'

describe Innsights::Report do
  before do 
    class Foo
      def some_method;end;
    end
  end
  let(:user)   { User.create}
  let(:report) { Innsights::Report.new("Mention", user: user) }

  describe '#initialize' do
    it 'Sets the action name' do
      report.name.should == "Mention"
    end
    it 'Sets the user' do
      report.user.object.should == user
    end
    it 'Can instantiate the action name' do
      r = Innsights::Report.new("Mention")
      r.name.should == "Mention"
    end
    it 'Can instantiate with action name and user' do
      r = Innsights::Report.new("Mention", user: user)
      r.name.should == "Mention"
      r.user.object.should == user
    end
    it 'Can instantiate action name and an option hash' do
      time = Time.now
      r = Innsights::Report.new("Mention", user: user, created_at: time)
      r.name.should == "Mention"
      r.user.object.should == user
      r.created_at.should == time
    end
    it 'Can add a group' do
      company = Company.new
      r = Innsights::Report.new("Mention", group: company)
      r.group.object.should == company
    end
    it 'Can add a created_at' do
      time = Time.now
      r = Innsights::Report.new("Mention", created_at: time)
      r.created_at.should == time
    end
    it 'Can add a single metic' do
      r = Innsights::Report.new("Mention", measure: {kg: 100})
      r.metrics.should == {kg: 100}
    end
    it 'Can add multiple metrics' do
      r = Innsights::Report.new("Mention", measure: {kg: 100, money: 200})
      r.metrics.should == {kg: 100, money: 200}
    end
    it 'Does not modify unspecified options' do
      r = Innsights::Report.new("Mention", created_at: Time.now, user: user)
      r.user.object.should == user
    end
  end
  describe '.run' do
    before do
      Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') 
      Innsights.client.stub(:report).and_return { true }
    end
    context 'With a report user' do
      it 'It users the report_user as the record' do
        Innsights.client.should_receive(:report).with(report.to_hash)
        report.run
      end
    end

    it "does not enqueues the job when there is no option setted" do
      Innsights.stub!(:enabled?){true}
      Resque.should_not_receive(:enqueue)
      Innsights.queue_system.should == nil
      report.run
    end

    it "enqueues the job with resque when the option is set" do
      Innsights.stub!(:enabled?){true}
      Innsights.stub(:queue_system){:resque}
      Resque.should_receive(:enqueue)
      report.run
    end

    it "enqueues the job with delayed_job when the option is set" do
      Innsights.stub!(:enabled?){true}
      Innsights.stub(:queue_system){:delayed_job}
      Innsights.client.stub_chain(:delay, :report).and_return(true)
      Innsights.client.should_receive(:delay)
      report.run
    end
    
  end
end
