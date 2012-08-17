require 'spec_helper'

describe Innsights do

  describe '#credentials' do
    before do
      Innsights.class_variable_set("@@credentials", nil)
    end
    let(:credential_hash) { {'app' => 'app', 'token' => 'token'} }
    context 'With Rails' do
      it 'Sets the credentials from the YAML file' do
        Innsights.should_receive(:credentials_from_yaml){credential_hash}
        Innsights.credentials.should == credential_hash
      end
    end
    context 'Without Rails' do
      before { Innsights.stub(:rails?){false} }
      it 'Sets the credentials from a hash' do
        Innsights.should_not_receive(:credentials_from_yaml)
        Innsights.credentials(credential_hash)
        Innsights.credentials.should == credential_hash
      end
    end
  end

  describe '#app_url' do
    before do
      Innsights.stub!(:credentials){{"app" => "subdomain", "token" => "token"}}
    end
    it 'Returns the full app url' do
      url = "#{Innsights.app_subdomain}.#{Innsights.url}/#{Rails.env}"
      Innsights.app_url.should == url
    end
  end

  describe "#mode" do
    before { Innsights.url = 'something.com' }

    it 'Sets the mode variable' do
      Innsights.mode :test
      Innsights.test_mode.should == true
    end
    it 'Sets the test_url when mode is test' do
      Innsights.mode :test
      Innsights.url.should == 'innsights.dev'
    end
    it 'Does not sets the test_url when mode is not test or staging' do
      Innsights.mode :production
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
      it 'Sets the enabled attr for the enviroment' do
        Innsights.stub(:current_env){'development'}
        Innsights.config :development do
          enable false
          mode :test
        end
        Innsights.enable_hash[:development].should == false
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

  describe '#group' do
    it 'Sets the group_class' do
      Innsights.should_receive(:group_class=).with(:school)
      Innsights.group(:School){}
    end

    it 'Evals the Group class when block is given' do
      Innsights::Config::Group.should_receive(:class_eval)
      Innsights.group(:Company){}
    end

    it 'Does not eval the Group class when no block is given' do
      Innsights::Config::Group.should_not_receive(:class_eval)
      Innsights.group(:Company)
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
      Innsights.mode :test
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

  describe '#report' do
    let(:user) { User.create }
    before do
      @report = Innsights::Config::GenericReport.new("Report name", user: user)
      Innsights::Config::GenericReport.stub!(:new){@report}
    end
    it 'Generates a Generic Report' do
      Innsights::Config::GenericReport.should_receive(:new).with("Report Name", user: user)
      Innsights.report("Report Name", user: user)
    end
    it 'Commits the report' do
      @report.should_receive(:commit)
      Innsights.report("Report Name", user: user)
    end
    it 'Returns the report' do
      Innsights.report("Report Name", user: user).should == @report
    end
  end

  describe 'enable' do
    it 'Sets the enable variable based on the enviroment'  do
      Innsights.enable :test, false
      Innsights.enable_hash[:test].should == false
    end
    it 'Uses the env_scope if no enviroment is passed' do
      Innsights.env_scope = :development
      Innsights.enable false
      Innsights.enable_hash[:development].should == false
    end
    it 'Sets the value for all enviroments when there no specific env' do
      Innsights.env_scope = nil
      Innsights.enable false
      Innsights.enable_hash.each do |k,v|
        Innsights.enable_hash[k].should == false
      end
    end
  end

  describe 'enabled?' do
    before do
      Innsights.stub(:current_env){'development'}
    end
    it 'Returns true when the current_env is enabled' do
      Innsights.enable :development, true
      Innsights.enabled?.should == true
    end
    it 'Returns false when the current_env is not enabled' do
      Innsights.enable :development, false
      Innsights.enabled?.should == false
    end 
    it 'Returns false when there is no key that matches the current_env' do
      Innsights.stub(:env){'testing'}
      Innsights.enabled?.should == false
    end

  end

  describe '#enviroments' do
    it 'Sets the user_env' do
      Innsights.enviroment 'new_env'
      Innsights.user_env.should == 'new_env'
    end
  end

  describe '#current_env' do
    it 'Returns the user env then speficied' do
      Innsights.should_receive(:user_env).twice{'new_env'} 
      Innsights.current_env.should == 'new_env'
    end
    it 'Returns the Rails env when rails is defined' do
      Innsights.user_env = nil
      Rails.should_receive(:env){'new_env'}
      Innsights.current_env.should == 'new_env'
    end
    it 'Returns the Rack env when rails is not defined' do
      ENV['RACK_ENV']= 'new_env'
      Innsights.stub(:rails?)
      Innsights.current_env.should == 'new_env'
    end
  end
end
