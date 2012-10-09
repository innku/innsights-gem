require 'spec_helper'

describe Innsights::Helpers::Config do
  
  let :klass do
    class DummyClass
      include Innsights::Helpers::Config
    end 
  end
  
  describe '.dsl' do
    it 'gives read/write to the local variable' do
      klass.dsl :method, :var
      klass.new.methods.should include(:var)
      klass.new.methods.should include(:var=)
    end
    
    it 'defines the dsl writer method' do
      klass.dsl :some_method, :some_var
      klass.new.methods.should include(:some_method)
    end
    
    it 'is able to assign a string' do
      klass.dsl :name_tag, :name
      object = klass.new
      object.name_tag 'My name'
      object.name.should == 'My name'
    end
    
    it 'is able to assign a block' do
      klass.dsl :block_tag, :block
      object = klass.new
      object.block_tag { 'Im in a block' }
      object.block.should be_a_kind_of(Proc)
    end

    it 'is able to assign a any other type' do
      klass.dsl :name_tag, :name
      object = klass.new
      object.name_tag 100
      object.name.should == 100
    end
  end

  describe '#dsl_call' do
    let(:post) { Post.create! }
    context 'When is a proc' do
      let(:proc) { lambda {|record| record.id } } 
      it 'Calls the Proc' do
        proc.should_receive(:call).with(post)
        klass.new.dsl_call(post, proc)
      end
      it 'Returns the called proc' do
        klass.new.dsl_call(post, proc).should == post.id
      end
      it 'Retuns nil when the proc raises an error' do
        proc.should_receive(:call).and_raise(RuntimeError)
        expect { klass.new.dsl_call(post, proc)}.not_to raise_error(RuntimeError)
      end
    end
    context 'When it is a symbol' do
      it 'Sends the method to the post' do
        post.stub!(:weight)
        post.should_receive(:weight)
        klass.new.dsl_call(post, :weight)
      end
      it 'It returns the evaluated method ' do
        post.stub!(:weight){200}
        klass.new.dsl_call(post, :weight).should ==  200
      end
    end
    context 'When it is a primitive value' do
      it 'Returns the value when is a Fixnum' do
        klass.new.dsl_call(post, 100).should ==  100
      end
    end  
    it 'Returns nil when NoMethodError' do
      klass.new.dsl_call(post, :i_dont_exist).should ==  nil
    end
  end
end
