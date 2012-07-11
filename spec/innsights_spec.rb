require 'spec_helper'

describe Innsights do

	describe ".queue" do
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

end
