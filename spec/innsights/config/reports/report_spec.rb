require 'spec_helper'

describe Innsights::Config::Report do

  before do 
    class DummyClass; end
    DummyClass.stub!(:after_create)
  end
  let(:report) { Innsights::Config::Report.new(DummyClass) }
  
  describe '.initialize' do
    let(:default_obj) { Innsights::Config::Report.new(DummyClass) }
    
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
      default_obj.klass.should == DummyClass
    end
  end

  
  describe '#run' do
    before do
      @client = mock("Innsights::Client", :report => nil)
      Innsights::Action.stub!(:new) { mock("Innsights::Action", :as_hash => {}) }
      Innsights.stub!(:client) { @client }
    end
    it 'Sets the record to report_user when no param is passed' do
      Innsights::Action.should_receive(:new).with(report, nil)
      report.run(nil)
    end
    it 'Uses the passed record when specified' do
      user = User.new
      Innsights::Action.should_receive(:new).with(report, user)
      report.run(user)
    end
    it 'calls the report method of the gems client' do
      Innsights.stub!(:enabled?){true}
      @client.should_receive(:report)
      report.run(nil)
    end

    it "does not enqueues the job when there is no option setted" do
      Innsights.stub!(:enabled?){true}
      Resque.should_not_receive(:enqueue)
      Innsights.queue_system.should == nil
      report.run(nil)
    end

    it "enqueues the job with resque when the option is set" do
      Innsights.stub!(:enabled?){true}
      Innsights.queue_system = :resque
      Resque.should_receive(:enqueue)
      report.run(nil)
    end

    it "enqueues the job with delayed_job when the option is set" do
      Innsights.stub!(:enabled?){true}
      Innsights.queue_system = :delayed_job
      Innsights.client.stub_chain(:delay, :report).and_return(true)
      Innsights.client.should_receive(:delay)
      report.run(nil)
    end

    it "does not report to Innsights when configuration is disabled" do
      Innsights.stub!(:enabled?){false}
      @client.should_not_receive(:report)
      report.run(nil)
    end
    it 'does not report to Innsights when the report condition is not met' do
      report.stub!(:valid?){false}
      report.should_receive(:valid?)
      @client.should_not_receive(:report)
      report.run(nil)
    end
  end

  describe '.measure' do
    it 'Adds the measure to the metrics' do
      report.measure :kg, with: :weight
      report.metrics.should == {kg: :weight}
    end
    it 'Sets the default method when no param passed for it' do
      report.measure :kg
      report.metrics.should == {kg: :kg}
    end
    it 'Can add multiple metrics' do
      report.measure :kg, with: :weight
      report.measure :money, with: :price
      report.metrics.should == {kg: :weight, money: :price}
    end
  end

  describe '.valid?' do
    it 'Returns false when the record is valid' do
      condition = lambda{|r| true}
      report.instance_variable_set("@condition", condition)
      report.should_receive(:dsl_attr).with(condition, record: nil){true}
      report.valid?(nil).should == true
    end
    it 'Returns true when the record is not valid' do
      condition = lambda{|r| false}
      report.instance_variable_set("@condition", condition)
      report.should_receive(:dsl_attr).with(condition, record: nil){false}
      report.valid?(nil).should == false
    end
    it 'Returns true when there is no condition' do
      report.instance_variable_set("@condition", nil)
      report.valid?(nil).should == true
    end
    it 'Returns true when the condition is explicitly true' do
      report.instance_variable_set("@condition", true)
      report.valid?(nil).should == true
    end
  end

  describe '.valid_for_push?' do
    it 'Is not valid for push' do
      report.valid_for_push?.should == false
    end
  end
  
end
