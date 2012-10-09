require 'spec_helper'

describe 'Report and Record integration' do
  let(:post) { Post.create!}
  before do
    Innsights.stub(:credentials){{app: "Innsights", toke: "123"}}
  end
  describe 'Controller Config' do
    let(:report) { Innsights::Config::Controller.new('users#create')}
    it 'Creates the correct hash when there the metric exist for record' do
      post.stub!(:price){200}
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Fetchers::Record.new(post, report).options
      hash[:measure].should == {kg: 100, money: 200}
    end
    it 'Creates the correct hash if no method' do
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Fetchers::Record.new(post, report).options
      hash[:measure].should == {kg: 100}
    end
  end
  describe 'Model Config' do
    let(:report) { Innsights::Config::Model.new(post.class)}
    it 'Creates the correct hash when there the metric exist for record' do
      post.stub!(:price){200}
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Fetchers::Record.new(post, report).options
      hash[:measure].should == {kg: 100, money: 200}
    end
    it 'Creates the correct hash if no method' do
      report.metrics = {kg: 100, money: :price}
      hash = Innsights::Fetchers::Record.new(post, report).options
      hash[:measure].should == {kg: 100}
    end
  end
end
