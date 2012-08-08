require 'dummy_app_spec_helper'

describe 'Report Model from Controller' do
  before do 
    Innsights::Config::ModelReport.any_instance.stub(:run){true}
    Innsights::Config::ControllerReport.any_instance.stub(:run){true}
    Innsights.stub_chain(:client,:report).and_return(true)
    Innsights.setup do
      user Dude do
        display :name
      end
    end
  end
  context 'When a controller action should report' do
    before do
      Innsights.setup do
        on 'dudes#index' do
          report 'dude_index'
          user   :current_dude
        end
      end
    end
    it 'Without a reporting model, it only reports the controller' do
      Innsights::Config::ControllerReport.any_instance.should_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_not_receive(:run)
      get dudes_path
    end
    it 'With a reporting model it reports the model and controller' do
      Innsights.setup do
        watch Dude do
          report 'Tweet'
        end
      end
      Innsights::Config::ControllerReport.any_instance.should_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_receive(:run)
      get dudes_path
    end

  end

  context 'When a controller action should not report' do
    it 'Without a reporting model, it does not report anything' do
      Innsights::Config::ControllerReport.any_instance.should_not_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_not_receive(:run)
      get dudes_path

    end
    it 'With a reporting model, it reports the model' do
      Innsights.setup do
        watch Dude do
          report 'Tweet'
        end
      end
      Innsights::Config::ControllerReport.any_instance.should_not_receive(:run)
      Innsights::Config::ModelReport.any_instance.should_receive(:run)
      get dudes_path
    end
  end
end
