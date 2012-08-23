require 'dummy_app_spec_helper'

describe Innsights::Config::GenericReport do
  let(:dude) { Dude.create(name: 'Adrian Cuadros') }
  let(:company) { Company.create(name: 'Innku') }
  before do 
    Innsights.stub_chain(:client, :report)
    Innsights.setup do
      user Dude do
        display :name
      end
      group Company do
        display :name
      end
    end
  end
  describe '#to_hash' do
    it 'renders the hash when there is no user' do
      hash = Innsights.report("Mention").to_hash
      hash.should == {report: {name: "Mention" }}
    end
    it 'renders the hash with a user' do
      hash = Innsights.report("Mention", user: dude).to_hash
      hash.should == {report: {name: "Mention", user: {display: dude.name, id: dude.id } }}
    end
    it 'renders the hash with a user and a group' do
      hash = Innsights.report("Mention", user: dude, group: company).to_hash
      hash.should == {report: {name: "Mention", user: {display: dude.name, id: dude.id }, group: {display: company.name, id: company.id} }}
    end
  end
  describe "#report" do
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
    context 'Generic report with dynamic Group name' do
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
      it 'Calls the new specified id' do
        company.should_receive(:new_id)
        Innsights.report('Mention', user: dude, group: company).run
      end
      it 'Calls the new specified display' do
        company.should_receive(:new_display)
        Innsights.report('Mention', user: dude, group: company).run
      end
      after do
        Innsights.group_id = @old_id
        Innsights.group_display = @old_display
      end
    end
  end
end
