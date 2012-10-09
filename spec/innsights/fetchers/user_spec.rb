require 'spec_helper'

describe Innsights::Fetchers::User do
  let(:group) { Company.create(name: 'New Company') }
  let(:user)  { User.create(name: 'New user', company: group) }
  let!(:user_fetcher) { Innsights::Fetchers::User.new(user) }
  
  describe '#initialize' do
    it 'sets the user object' do
      user_fetcher.object.should == user
    end
  end
  describe '#to_hash' do
    it 'returns the users app_id and display as hash' do
      user_fetcher.to_hash.should == {id: user.id, display: user.to_s}
    end
  end
  describe '#app_id' do
    it 'returns the given id call for the user' do
      user_fetcher.app_id.should == user.id
    end
  end
  describe '#display' do
    it 'returns the given display call for the user' do
      user_fetcher.display.should == user.to_s
    end
  end
  describe '#group' do
    it 'returns the group of the company when the group call is set' do
      Innsights.group_call = :company
      user_fetcher.group.should == group
    end
    it 'returns nothing when the group call isnt set' do
      user_fetcher.group.should == nil
    end
  end
  after(:each) do
    Innsights.group_call = nil
    Innsights.user_id = :id
    Innsights.user_display = :to_s
  end
end
