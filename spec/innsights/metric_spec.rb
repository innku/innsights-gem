require 'spec_helper'

describe Innsights::Metric do
  let!(:report) { Innsights::Config::Report.new(Post) }

  describe 'instantiate' do
    it 'Accepts the name and value as parameters' do
      metric = Innsights::Metric.new(:kg, 100)
      metric.instance_variable_get('@name').should == :kg
      metric.instance_variable_get('@value').should == 100
    end

    it 'Symbolizes the name' do
      metric = Innsights::Metric.new('kg', 100)
      metric.instance_variable_get('@name').should == :kg
    end
  end

  describe '.as_array_for_user' do
    let(:user) { User.create!}
    let(:metric) { Innsights::Metric.new(:kg, :weight) }
    it 'Returns an array with the name and value' do
      metric.should_receive(:process_value_for_user){100}
      metric.as_array_for_user(user).should == [:kg, 100]
    end
  end

  describe '.process_value_for_user' do
    let(:user) { User.create!}
    context 'When is a proc' do
      let(:metric) { Innsights::Metric.new(:kg, lambda{|user| user.id }) }

      it 'Calls the Proc' do
        metric.value.should_receive(:call).with(user)
        metric.process_value_for_user(user)
      end
      it 'Returns the called proc' do
        metric.process_value_for_user(user).should == user.id
      end
      it 'Retuns nil when the proc raises an error' do
        metric.value.should_receive(:call).and_raise(RuntimeError)
        metric.process_value_for_user(user).should == nil
      end
    end
    context 'When is not a proc' do
      it 'Returns the value when is a Fixnum' do
        metric = Innsights::Metric.new(:kg, 100)
        metric.process_value_for_user(user).should ==  100
      end
      it 'Sends the method to the user' do
        user.stub!(:weight)
        metric = Innsights::Metric.new(:kg, :weight)
        user.should_receive(:weight)
        metric.process_value_for_user(user)
      end
      it 'It returns the evaluated method ' do
        user.stub!(:weight){200}
        metric = Innsights::Metric.new(:kg, :weight)
        metric.process_value_for_user(user).should ==  200
      end
      it 'Returns nil when NoMethodError' do
        metric = Innsights::Metric.new(:kg, :weight)
        metric.process_value_for_user(user).should ==  nil
      end
    end
  end
  
end
