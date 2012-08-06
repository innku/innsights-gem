require 'spec_helper'
include Innsights::Helpers::Tasks

describe Innsights::Helpers::Tasks do
  describe '#push' do
    before do
      Innsights::Helpers::Tasks.stub(:upload_content)
      Post.create!
    end
    let(:action_hash) {{:report=>{:name=>"Post", :created_at=>Time.now}}}
    let(:report){ Innsights::Config::ModelReport.new(Post) }

    context 'With a report valid for push' do
      before do
        report.stub(:valid_for_push?){ true }
      end
      it 'Updates the progress action' do
        Innsights::Helpers::Tasks.should_receive(:progress_actions).with(report.klass)
        Innsights::Helpers::Tasks.push(report)
      end
      it 'Creates a new action' do
        Innsights::Action.stub_chain(:new, :as_hash){ action_hash }
        Innsights::Action.should_receive(:new)
        Innsights::Helpers::Tasks.push(report)
      end
      it 'Upload the contents when there are reports' do
        action_hash = {:report=>{:name=>"Post", :created_at=>Time.now}}
        Innsights::Helpers::Tasks.should_receive(:upload_content).with([action_hash].to_json)
        Innsights::Helpers::Tasks.push(report)
      end
      it 'Does not upload the contents when there are no reports' do
        Post.stub(:find_each){[]}
        Innsights::Helpers::Tasks.should_not_receive(:upload_content)
        Innsights::Helpers::Tasks.push(report)
      end
    end
    context 'With a report not valid for push' do
      before do
        report.stub(:valid_for_push?){ false }
      end

      it 'Does not push the report' do
        Innsights::Helpers::Tasks.should_not_receive(:progress_actions)
        Innsights::Helpers::Tasks.should_not_receive(:upload_content)
        Innsights::Helpers::Tasks.push(report)
      end
    end
  end

  describe '#progress_actions' do
    let(:report){ Innsights::Config::ModelReport.new(Post) }

    it 'Sets up the progress bar' do
      progress_bar = ProgressBar.new(report.klass.to_s.pluralize, 100)
      ProgressBar.should_receive(:new){progress_bar}
      Innsights::Helpers::Tasks.push(report)
    end
    it 'Finds each record of the klass'  do
      report.klass.should_receive(:find_each)
      Innsights::Helpers::Tasks.push(report)
    end
    it 'It displays an error if klass does not have a find_each' do
      report = Innsights::Config::ModelReport.new(String)
      lambda{ Innsights::Helpers::Tasks.push(report) }.should_not raise_error
    end
    it 'Updates the bar even if an error is rescued' do
      ProgressBar.any_instance.should_receive(:finish)
      report = Innsights::Config::ModelReport.new(String)
      Innsights::Helpers::Tasks.push(report)
    end
  end

  describe '#upload_content' do
    let(:action_hash) {[{:report=>{:name=>"Post", :created_at=>Time.now}}]}
    let(:json)        {action_hash.to_json}
    context 'With a client' do
      before do
        Innsights.stub(:client) {true} 
        Innsights.stub_chain(:client, :push)
      end
      it 'Opens the temp file' do
        Tempfile.should_receive(:open).with('innsights')
        Innsights::Helpers::Tasks.upload_content(json)
      end
      it 'Writes the content' do
        File.any_instance.should_receive(:write).with(json)
        Innsights::Helpers::Tasks.upload_content(json)
      end
      it 'Rewinds the file' do
        File.any_instance.should_receive(:rewind)
        Innsights::Helpers::Tasks.upload_content(json)
      end
      it 'Push them to innsights' do
        Innsights.client.should_receive(:push).with(instance_of(Tempfile))
        Innsights::Helpers::Tasks.upload_content(json)
      end
    end
    context 'Without a client' do
      before { Innsights.stub(:client) {false} }
      it 'Does not open the file' do
        Tempfile.should_not_receive(:open)
        Innsights::Helpers::Tasks.upload_content(json)
      end
      it 'Does not push it' do
        Innsights.client.should_not_receive(:push)
        Innsights::Helpers::Tasks.upload_content(json)
      end
    end

  end
end
