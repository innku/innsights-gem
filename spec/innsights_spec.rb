require 'spec_helper'

describe Innsights do

  describe "#queue" do
    it "can't set it to a not suported queue system" do
      Innsights.queue_system = nil
      Innsights.queue :other_queue_system
      Innsights.queue_system.should == nil
    end
    it "supports resque" do
      Innsights.queue :resque
      Innsights.queue_system.should == :resque
    end
    it "supports delayed_job" do
      Innsights.queue :delayed_job
      Innsights.queue_system.should == :delayed_job
    end
  end

  describe "#test_mode" do
    it 'calls the test_mode= method' do
      Innsights.should_receive(:test_mode=)
      Innsights.test "on"
    end
  end

  describe "#config" do
    context "Without an env parameter" do
      it "runs the appropiate config options" do
        Innsights.should_receive(:queue).with(:resque)
        Innsights.should_receive(:test).with(:on)
        Innsights.config do
          queue :resque
          test :on
        end
      end
    end

    context "With an env parameter" do
      before { Rails.stub!(:env).and_return('test') }

      it "sets the action for the specified enviroment" do
        Innsights.should_receive(:queue).with(:resque)
        Innsights.should_receive(:test).with(:on)
        Innsights.config :test do
          queue :resque
          test :on
        end
      end

      it "When multiple envs are passed it sets them for all of them" do
        Innsights.should_receive(:queue).twice.with(:resque)
        Innsights.config :test, :development do 
          queue :resque
        end

        Rails.stub!(:env).and_return('development')
        Innsights.config :test, :development do 
          queue :resque
        end
      end

      it "does not set the actions for other enviroments" do
        Innsights.should_not_receive(:queue).with(:resque)
        Innsights.config :development do
          queue :resque
        end
      end
    end
  end

  describe '#watch' do
    before do 
      class DummyClass; end
      @report = Innsights::Config::ModelReport.new(DummyClass)
      Innsights::Config::ModelReport.stub!(:new){@report}
    end
    it 'Creates the report with a class when there is a param' do
      Innsights::Config::ModelReport.should_receive(:new).with(DummyClass)
      Innsights.watch('Foo',{class: DummyClass}){}
    end
    it 'Creates the report with a class when there is no param' do
      Innsights::Config::ModelReport.should_receive(:new).with(DummyClass)
      Innsights.watch(DummyClass){}
    end
    it 'Evals the report instance' do
      @report.should_receive(:instance_eval)
      Innsights.watch(DummyClass){}
    end
    it 'Commit the report' do
      @report.should_receive(:commit)
      Innsights.watch(DummyClass){}
    end
  end

  describe "#after" do
    before do
      Innsights.test_mode = true
    end
    it 'sets the apropiate methods'  do
      Innsights::Config::ControllerReport.any_instance.should_receive(:report).with('User Created')
      Innsights::Config::ControllerReport.any_instance.should_receive(:user).with(:current_user)
      Innsights.on "users#create" do
        report 'User Created'
        user   :current_user
      end
    end

    it 'commits the report' do
    Innsights::Config::ControllerReport.any_instance.should_receive(:commit)
    Innsights.on "users#create" do
        report 'User Created'
        user   :current_user
      end
    end
  end

  describe '#report' do
    let(:user) { User.create }

    before do
      @report = Innsights::Config::GenericReport.new("Report name", user)
      Innsights::Config::GenericReport.stub!(:new){@report}
    end

    it 'Generates a Generic Report' do
      Innsights::Config::GenericReport.should_receive(:new).with("Report Name", user)
      Innsights.report("Report Name", user)
    end
    it 'Commits the report' do
      @report.should_receive(:commit)
      Innsights.report("Report Name", user)
    end
    it 'Returns the report' do
      Innsights.report("Report Name", user).should == @report
    end
  end
end
