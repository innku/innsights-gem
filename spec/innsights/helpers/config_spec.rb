require 'spec_helper'

describe Innsights::Helpers::Config do
  
  let :klass do
    class DummyClass
      include Innsights::Helpers::Config
    end 
  end
  
  describe '.dsl_attr' do
    it 'gives read/write to the local variable' do
      klass.dsl_attr :var, :method
      klass.new.methods.should include(:var)
      klass.new.methods.should include(:var=)
    end
    
    it 'defines the dsl writer method' do
      klass.dsl_attr :some_var, :some_method
      klass.new.methods.should include(:some_method)
    end
    
    it 'is able to assign a string' do
      klass.dsl_attr :name, :name_tag
      object = klass.new
      object.name_tag 'My name'
      object.name.should == 'My name'
    end
    
    it 'is able to assign a block' do
      klass.dsl_attr :block, :block_tag
      object = klass.new
      object.block_tag { 'Im in a block' }
      object.block.should be_a_kind_of(Proc)
    end

    it 'is able to assign a any other type' do
      klass.dsl_attr :name, :name_tag
      object = klass.new
      object.name_tag 100
      object.name.should == 100
    end
  end

  describe '.process_object' do

  end
  
  describe '.process_object' do
    let(:post) { Post.create!}
    context 'With a record' do
      context 'When is a proc' do
        let(:metric) { Innsights::Metric.new(:kg, lambda{|post| post.id }) }
        let(:value) {metric.value} 

        it 'Calls the Proc' do
          metric.value.should_receive(:call).with(post)
          metric.process_object(post, value)
        end
        it 'Returns the called proc' do
          metric.process_object(post, value).should == post.id
        end
        it 'Retuns nil when the proc raises an error' do
          metric.value.should_receive(:call).and_raise(RuntimeError)
          metric.process_object(post, value).should == nil
        end
      end
      context 'When is not a proc' do
        it 'Returns the value when is a Fixnum' do
          metric = Innsights::Metric.new(:kg, 100)
          value = metric.value
          metric.process_object(post, metric.value).should ==  100
        end
        it 'Sends the method to the post' do
          post.stub!(:weight)
          metric = Innsights::Metric.new(:kg, :weight)
          value = metric.value
          post.should_receive(:weight)
          metric.process_object(post, metric.value)
        end
        it 'It returns the evaluated method ' do
          post.stub!(:weight){200}
          metric = Innsights::Metric.new(:kg, :weight)
          metric.process_object(post, metric.value).should ==  200
        end
        it 'Returns nil when NoMethodError' do
          metric = Innsights::Metric.new(:kg, :weight)
          metric.process_object(post, metric.value).should ==  nil
        end
      end
    end

    context 'Without a record' do
      it 'Returns the fixnum when there is a fixnum' do
          metric = Innsights::Metric.new(:kg, 100)
          metric.process_object(metric.value).should ==  100
      end
      it 'Returns nil when there is no fixnum' do
          metric = Innsights::Metric.new(:kg, :some_method)
          metric.process_object(metric.value).should ==  nil
      end
    end
  end
end
