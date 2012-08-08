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
  end
  
end
