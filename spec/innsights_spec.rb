require 'spec_helper'

describe Innsights do

  describe "#queue" do
    it "can't set it to a not suported queue system" do
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

end
