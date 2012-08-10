require 'spec_helper'

describe Innsights do

  describe '#app_url' do
    before do
      Innsights.stub!(:credentials){{"app" => "subdomain", "token" => "token"}}
    end
    it 'Returns the full app url' do
      url = "#{Innsights.app_subdomain}.#{Innsights.url}/#{Rails.env}"
      Innsights.app_url.should == url
    end
  end

  describe "#test_mode" do
    before { Innsights.url = 'something.com' }

    it 'Sets the test_mode variable' do
      Innsights.test_mode=true
      Innsights.test_mode.should == true
    end
    it 'Sets the test_url when test_mode is true' do
      Innsights.test_mode=true
      Innsights.url.should == 'innsights.dev'
    end
    it 'Does not sets the test_url when test_mode is not true' do
      Innsights.test_mode=false
      Innsights.url.should_not == 'innsights.dev'
    end
  end

  describe "#setup" do
    before do
      Innsights.stub!(:credentials){{"app" => "subdomain", "token" => "token"}}
    end
    it 'Evals the instance with the block'  do
      Innsights.stub!(:instance_eval)
      Innsights.should_receive(:instance_eval)
      Innsights.setup{}
    end
    it 'Creates a client' do
      Innsights::Client.should_receive(:new)
      Innsights.setup{}
    end
    it 'Sets the client' do
      Innsights.should_receive(:client=).with(instance_of(Innsights::Client))
      Innsights.setup{}
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

  describe '#user' do
    it 'Sets the user call depending on the class' do
      Innsights.should_receive(:user_call=).with(:user)
      Innsights.user(User)
    end
    it 'Evals the User class when block is given' do
      Innsights::Config::User.should_receive(:class_eval)
      Innsights.user(User){}
    end
    it 'Does not eval the User class when no block is given' do
      Innsights::Config::User.should_not_receive(:class_eval)
      Innsights.user(User)
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

  describe "#on" do
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

  describe "#test" do
    it 'calls the test_mode= method' do
      Innsights.should_receive(:test_mode=)
      Innsights.test "on"
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
