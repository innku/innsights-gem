require 'spec_helper'
require 'delayed_job'
require 'action_controller'

describe Innsights::Config::ControllerReport do
  before do
    Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') 
    Innsights.client.stub(:report).and_return { true }
  end
  let(:report) { Innsights::Config::ControllerReport.new("users#create") }

  describe '.initialize' do
    it 'sets the created_at default' do
      report.controller.should  == "users"
    end
    it 'sets the created_at default' do
      report.action.should  == "create"
    end
  end

  describe '.dsl_attrs' do
    it 'Sets event name as :catalyst' do
      report.catalyst 'users#create'
      report.event_name.should == "users#create"
    end

    it 'Sets report_user as user' do
      report.user :current_dude
      report.report_user.should == :current_dude
    end
  end

  describe '.commit' do
    before do
      report.action_name = "User Created"
      report.event_name = 'users#create'
    end
    context 'With an invalid class' do
      it 'Does not raises an error' do
        lambda{ report.commit }.should_not raise_error
      end
    end
    context 'With a valid class' do
      before do 
        class UsersController < ActionController::Base
          def create; end
        end
      end
      it 'Adds the it to the Innsights reports' do
        Innsights.reports.should_receive(:<<).with(report)
        report.commit
      end
    end
  end

  describe '.add_report_to_innsights' do
    before do 
      class UsersController < ActionController::Base
        def create; end
      end
    end
    it 'Opens the class for class eval' do
      UsersController.should_receive(:class_eval)
      report.add_report_to_innsights(UsersController,  "User Created", report, 'create')
    end
    it 'Adds the innsights_reports accessor' do
      report.add_report_to_innsights(UsersController,  "User Created", report, 'create')
      lambda { UsersController.innsights_reports}.should_not raise_error
    end
    it 'Adds the report to the class innsights_report' do
      report.add_report_to_innsights(UsersController,  "User Created", report, 'create')
      UsersController.innsights_reports["User Created"].should == report
    end
    it 'Should also call report_to_innsights when calling the desired action' do
      report.add_report_to_innsights(UsersController,  "User Created", report, 'create')
      f = UsersController._process_action_callbacks.select{|f| f.kind == :after}
      f.first.options[:only].should == :create
    end
  end
end

