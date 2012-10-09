require 'dummy_app_spec_helper'


describe DudesController do
  before do 
    Innsights::Config::Controller.any_instance.stub(:run){true}
  end

  describe 'Innsights report proccess' do
    before do
      Innsights.setup do
        on 'dudes#index' do
          report 'dude_index'
          user   :current_dude
        end
      end
    end

    context 'In the corresponding action' do
      it 'Reports to innsights' do
        DudesController.innsights_reports['dude_index'].should_receive(:run)
        get 'index'
      end

      it 'It only adds the filter to the apropiate action' do
        get 'index'
        f = DudesController._process_action_callbacks.select{|f| f.kind == :after}.first
        f.options[:only].to_sym.should == :index
      end

      it 'Can report from multiple actions' do
        Innsights.setup do
          on 'dudes#new' do
            report 'dude_new'
            user   :current_dude
          end
        end
        DudesController.innsights_reports['dude_index'].should_receive(:run)
        DudesController.innsights_reports['dude_new'].should_receive(:run)
        get 'index'
        get 'new'
      end
    end

    context 'In other action' do
      it 'Does not reports to innsights' do
        Innsights::Config::Controller.any_instance.should_not_receive(:run)
        get 'new'
      end
    end
  end

end

