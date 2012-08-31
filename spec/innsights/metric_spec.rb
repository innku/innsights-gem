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
    let(:metric) { Innsights::Metric.new(:kg, 100.2) }
    it 'Returns an array with the name and value' do
      metric.as_array(post).should == [:kg, 100.2]
    end
    it 'Returns nil when the process_object is nil' do
      metric.should_receive(:process_object){nil}
      metric.as_array(post).should == nil
    end
  end
end
