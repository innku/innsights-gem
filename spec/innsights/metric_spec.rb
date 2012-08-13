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

  describe '.as_array' do
    let(:post) { Post.create!}
    let(:metric) { Innsights::Metric.new(:kg, :weight) }
    it 'Returns an array with the name and value' do
      metric.should_receive(:process_value){100}
      metric.as_array(post).should == [:kg, 100]
    end
    it 'Returns nil when the process_value is nil' do
      metric.should_receive(:process_value){nil}
      metric.as_array(post).should == nil
    end
  end

  describe '.process_value' do
    let(:post) { Post.create!}
    context 'With a record' do
      context 'When is a proc' do
        let(:metric) { Innsights::Metric.new(:kg, lambda{|post| post.id }) }

        it 'Calls the Proc' do
          metric.value.should_receive(:call).with(post)
          metric.process_value(post)
        end
        it 'Returns the called proc' do
          metric.process_value(post).should == post.id
        end
        it 'Retuns nil when the proc raises an error' do
          metric.value.should_receive(:call).and_raise(RuntimeError)
          metric.process_value(post).should == nil
        end
      end
      context 'When is not a proc' do
        it 'Returns the value when is a Fixnum' do
          metric = Innsights::Metric.new(:kg, 100)
          metric.process_value(post).should ==  100
        end
        it 'Sends the method to the post' do
          post.stub!(:weight)
          metric = Innsights::Metric.new(:kg, :weight)
          post.should_receive(:weight)
          metric.process_value(post)
        end
        it 'It returns the evaluated method ' do
          post.stub!(:weight){200}
          metric = Innsights::Metric.new(:kg, :weight)
          metric.process_value(post).should ==  200
        end
        it 'Returns nil when NoMethodError' do
          metric = Innsights::Metric.new(:kg, :weight)
          metric.process_value(post).should ==  nil
        end
      end
    end

    context 'Without a record' do
      it 'Returns the fixnum when there is a fixnum' do
          metric = Innsights::Metric.new(:kg, 100)
          metric.process_value.should ==  100
      end
      it 'Returns nil when there is no fixnum' do
          metric = Innsights::Metric.new(:kg, :some_method)
          metric.process_value.should ==  nil
      end
    end
  end

end
