require 'dummy_app_spec_helper'

describe Innsights::Report do
  let(:dude) { User.create(name: 'Adrian Cuadros') }
  let(:company) { Company.create(name: 'Innku') }
  before do 
    Innsights::Config::Model.any_instance.stub(:run){true}
    Innsights::Config::Controller.any_instance.stub(:run){true}
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
      Timecop.freeze Time.now do
        hash = Innsights.report("Mention").to_hash
        hash.should == {report: {name: "Mention", created_at: Time.now }}
      end
    end
    it 'renders the hash with a created_at' do
      created_at = Time.now
      hash = Innsights.report("Mention", created_at: created_at).to_hash
      hash.should == {report: {name: "Mention", created_at: created_at }}
    end
    it 'renders the hash with a user' do
      Timecop.freeze Time.now do
        hash = Innsights.report("Mention", user: dude).to_hash
        hash.should == {report: {name: "Mention", user: {display: dude.name, id: dude.id }, created_at: Time.now }}
      end
    end
    it 'renders the hash with a user and a group' do
      Timecop.freeze Time.now do
        hash = Innsights.report("Mention", user: dude, group: company).to_hash
        hash.should == {report: {name: "Mention", user: {display: dude.name, id: dude.id }, group: {display: company.name, id: company.id}, created_at: Time.now }}
      end
    end
    it 'renders the hash with a aggregates for the action' do
      Timecop.freeze Time.now do
        hash = Innsights.report("Mention", source: 'non-follower').to_hash
        hash.should == {report: {name: "Mention", source: 'non-follower', created_at: Time.now }}
      end
    end
  end
  describe "#report" do
    it 'Can report a manual action' do
      Innsights.client.should_receive(:report)
      Innsights.report('Mention', user: dude).run
    end
    it 'Can create a custom create action' do
      Dude.after_create lambda {|record| Innsights.report('Mention').run }
      Innsights.client.should_receive(:report)
      Dude.create!
    end
    context 'Generic report with dynamic Group name' do
      let(:dude) { Dude.create name: 'Adrian'}
      let(:company) { Company.create name: 'Innku'}
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
