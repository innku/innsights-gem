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
    let(:metric) { Innsights::Metric.new(:kg, 100) }
    it 'Returns an array with the name and value' do
      metric.as_array.should == [:kg, 100]
    end
  end
end
