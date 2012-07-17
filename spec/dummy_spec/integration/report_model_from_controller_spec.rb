require 'dummy_app_spec_helper'

describe 'Report Model from Controller' do
  before do 
    Innsights::Config::ModelReport.any_instance.stub(:run){true}
    Innsights::Config::ControllerReport.any_instance.stub(:run){true}
    Innsights.setup do
      user User do
        display :username
      end
    end
  end

  context 'When a controller action should not report' do
    it 'With a reporting model, it reports the model' do
      Innsights.setup do
        watch User do
          report 'Tweet'
        end
      end
      Innsights::Config::ControllerReport.any_instance.should_not_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_receive(:run)
      get users_path

    end
    it 'Without a reporting model, it does not report anything' do
      Innsights::Config::ControllerReport.any_instance.should_not_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_not_receive(:run)
      get users_path

    end
  end
  context 'When a controller action should report' do
    before do
      Innsights.setup do
        on 'users#index' do
          report 'user_index'
          user   :current_user
          is_user true
        end
      end
    end
    it 'With a reporting model it reports the model and controller' do
      Innsights.setup do
        watch User do
          report 'Tweet'
        end
      end
      Innsights::Config::ControllerReport.any_instance.should_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_receive(:run)
      get users_path
    end

    it 'Without a reporting model, it only reports the controller' do
      Innsights::Config::ControllerReport.any_instance.should_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_not_receive(:run)
      get users_path
    end
  end


end
