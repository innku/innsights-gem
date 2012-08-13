require 'spec_helper'

describe 'Report and Action integration' do
  let(:post) { Post.create!}
  before do
    Innsights.stub(:credentials){{app: "Innsights", toke: "123"}}
  end
  describe 'Controller Reports' do
    let(:report) { Innsights::Config::ControllerReport.new('users#create')}
    it 'Creates the correct hash when there the metric exist for record' do
      post.stub!(:price){200}
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Action.new(report, post).as_hash
      hash[:report][:metrics].should == {kg: 100, money: 200}
    end
    it 'Creates the correct hash if no method' do
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Action.new(report, post).as_hash
      hash[:report][:metrics].should == {kg: 100}
    end
  end
  describe 'Generic Reports' do
    it 'Creates the correct hash when there is no record' do
      report = Innsights::Config::GenericReport.new("Metric", metrics: {kg: 100, money: 200})
      hash = Innsights::Action.new(report, nil).as_hash
      hash[:report][:metrics].should == {kg: 100, money: 200}
    end
  end
  describe 'DSL Reports' do
    let(:report) { Innsights::Config::ModelReport.new(post.class)}

    it 'Creates the correct hash when there the metric exist for record' do
      post.stub!(:price){200}
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Action.new(report, post).as_hash
      hash[:report][:metrics].should == {kg: 100, money: 200}
    end
    it 'Creates the correct hash if no method' do
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Action.new(report, post).as_hash
      hash[:report][:metrics].should == {kg: 100}
    end
  end
end
