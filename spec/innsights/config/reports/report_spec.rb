require 'spec_helper'
require 'delayed_job'

describe Innsights::Config::Report do

  before do 
    class Dummy; end
    Dummy.stub!(:after_create)
  end
  let(:report) { Innsights::Config::Report.new(Dummy) }
  
  describe '.initialize' do
    let(:default_obj) { Innsights::Config::Report.new(Dummy) }
    
    it 'sets the created_at default' do
      default_obj.created_at.should  == :created_at
    end
    it 'sets the event name default' do
      default_obj.event_name.should  == :create
    end
    it 'sets the report user default' do
      default_obj.report_user.should == :user
    end
    it 'sets the klass to param' do
      default_obj.klass.should == Dummy
    end
  end
  
  
  describe '#run' do
    before do
      @client = mock("Innsights::Client", :report => nil)
      Innsights::Action.stub!(:new) { mock("Innsights::Action", :as_hash => {}) }
      Innsights.stub!(:client) { @client }
    end
    it 'Sets the record to report_user when no param is passed' do
      Innsights::Action.should_receive(:new).with(report, report.report_user)
      report.run(nil)
    end
    it 'Uses the passed record when specified' do
      user = User.new
      Innsights::Action.should_receive(:new).with(report, user)
      report.run(user)
    end
    it 'calls the report method of the gems client' do
      Innsights.enabled = true
      @client.should_receive(:report)
      report.run(nil)
    end

    it "does not enqueues the job when there is no option setted" do
      Innsights.enabled = true
      Resque.should_not_receive(:enqueue)
      Innsights.queue_system.should == nil
      report.run(nil)
    end

    it "enqueues the job with resque when the option is set" do
      Innsights.enabled = true
      Innsights.queue_system = :resque
      Resque.should_receive(:enqueue)
      report.run(nil)
    end

    it "enqueues the job with delayed_job when the option is set" do
      Innsights.enabled = true
      Innsights.queue_system = :delayed_job
      Innsights.client.stub_chain(:delay, :report).and_return(true)
      Innsights.client.should_receive(:delay)
      report.run(nil)
    end

    it "doesnt call the report method when configuration is disabled" do
      Innsights.enabled = false
      @client.should_not_receive(:report)
      report.run(nil)
    end
  end

  describe '.valid_for_push?' do
    it 'Is not valid for push' do
      report.valid_for_push?.should == false
    end
  end
  
end
