require 'dummy_app_spec_helper'


describe UsersController do
  before do 
    Innsights::Config::ControllerReport.any_instance.stub(:run){true}
  end

  describe 'Innsights report proccess' do
    before do
      Innsights.setup do
        on 'users#index' do
          report 'user_index'
          user   :current_user
          is_user true
        end
      end
    end

    context 'In the corresponding action' do
      it 'Reports to innsights' do
        UsersController.innsights_reports['user_index'].should_receive(:run).with(:current_user)
        get 'index'
      end

      it 'It only adds the filter to the apropiate action' do
        get 'index'
        f = UsersController._process_action_callbacks.select{|f| f.kind == :after}.first
        f.options[:only].should == :index
      end

      it 'Can report from multiple actions' do
        Innsights.setup do
          on 'users#new' do
            report 'user_new'
            user   :current_user
            is_user true
          end
        end
        UsersController.innsights_reports['user_index'].should_receive(:run).with(:current_user)
        UsersController.innsights_reports['user_new'].should_receive(:run).with(:current_user)
        get 'index'
        get 'new'
      end
    end

    context 'In other action' do
      it 'Does not reports to innsights' do
        Innsights::Config::ControllerReport.any_instance.should_not_receive(:run)
        get 'new'
      end
    end
  end

end

