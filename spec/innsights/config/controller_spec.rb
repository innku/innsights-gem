require 'spec_helper'
require 'action_controller'

describe Innsights::Config::Controller do
  before do
    Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') 
    Innsights.client.stub(:report).and_return { true }
  end
  let(:report) { Innsights::Config::Controller.new("users#create") }

  describe '.initialize' do
    it 'sets the created_at default' do
      report.controller_name.should  == "users"
    end
    it 'sets the created_at default' do
      report.action_name.should  == "create"
    end
  end

  describe '.dsl_attrs' do
    it 'Sets report_user as user' do
      report.user :current_dude
      report.report_user.should == :current_dude
    end
  end

  describe '.commit' do
    before do
      report.name = "User Created"
      class UsersController < ActionController::Base
        def create; end
      end
    end
    context 'With an invalid class' do
      it 'Does not raises an error' do
        lambda{ report.commit }.should_not raise_error
      end
    end
    context 'With a valid class' do
      it 'Adds the it to the Innsights reports' do
        Innsights.reports.should_receive(:<<).with(report)
        report.commit
      end
      it 'Sends an after_filter message to the class' do
        UsersController.should_receive(:after_filter)
        report.commit
      end
      it 'Adds the innsights_reports accessor' do
        report.commit
        lambda { UsersController.innsights_reports }.should_not raise_error
      end
      it 'Adds the report to the class innsights_report' do
        report.commit
        UsersController.innsights_reports["User Created"].should == report
      end
      it 'Should also call report_to_innsights when calling the desired action' do
        report.commit
        f = UsersController._process_action_callbacks.select{|f| f.kind == :after}
        f.first.options[:only].to_sym.should == :create
      end
    end
    context 'Error handling' do
      before do
        class PeopleController
        end
      end
      let(:report) { Innsights::Config::Controller.new("persons#create") }
      it 'Does not crash when there is no after_filter method' do
        report = Innsights::Config::Controller.new("persons#create")
        lambda { report.commit }.should_not raise_error
      end
      it 'Does not crash if the controller action does not exist' do
        lambda { 
          report = Innsights::Config::Controller.new("users#not")
          report.commit
        }.should_not raise_error
      end
    end
  end
end

