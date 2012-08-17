require 'dummy_app_spec_helper'

describe 'Generic Report' do
  before do 
    Innsights.stub_chain(:client, :report)
    Innsights.setup do
      user Dude do
        display :name
      end
    end
  end

  let(:dude) { Dude.create!}

  it 'Can report a manual action' do
    Innsights.client.should_receive(:report)
    Innsights.report('Mention', dude).run
  end

  it 'Can create a custom create action' do
    Dude.class_eval do
      after_create :manual_create
      def manual_create
        Innsights.report('Mention', self).run
      end
    end
    Innsights.client.should_receive(:report)
    Dude.create!
  end

  describe 'Generic report with dynamic Group name' do
    let(:dude) { Dude.create!}
    let(:company) { Company.create!}
    before do
      @old_id = Innsights.group_id
      @old_display = Innsights.group_display
      Innsights.setup do
        group :Company do
          id :new_id
          display :new_display
        end
      end
      company.stub!(:new_id)
      company.stub!(:new_display)
    end

    after do
      Innsights.group_id = @old_id
      Innsights.group_display = @old_display
    end
    it 'Calls the new specified id' do
      company.should_receive(:new_id)
      Innsights.report('Mention', user: dude, group: company).run
    end

    it 'Calls the new specified display' do
      company.should_receive(:new_display)
      Innsights.report('Mention', user: dude, group: company).run

    end

  end

end
