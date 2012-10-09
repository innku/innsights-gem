require 'spec_helper'

describe Innsights::Fetchers::Group do

  let(:group)   { Company.create(:name => 'New Company') }
  let!(:action_group) { Innsights::Fetchers::Group.new(group)}

  describe '#initialize' do
    it 'Sets the object ' do
      action_group.instance_variable_get("@object").should == group
    end
  end

  describe '#app_id' do
    it 'returns the group innsights group call of the objets id' do
      action_group.app_id.should == group.id
    end
    it 'returns the group non default id' do
      Innsights.group_id = :class
      action_group.app_id.should == group.class
    end
  end

  describe '#display' do
    it 'returns the group to_s display' do
      action_group.display.should == group.to_s
    end
    it 'returns the group non default display' do
      Innsights.group_display = :name
      action_group.display.should == group.name
    end
  end

  describe '#to_hash' do
    it 'returns the right group hash' do
      action_group = Innsights::Fetchers::Group.new(group)
      action_group.to_hash.should == {:id => group.id, :display => group.to_s}
    end
  end
  
  after(:each) do
    Innsights.group_id = :id
    Innsights.group_display = :to_s
  end

end
