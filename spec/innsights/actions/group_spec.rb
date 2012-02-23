require 'spec_helper'

describe Innsights::Actions::Group do
  before { Innsights.group_call = :company }
  let!(:report) { Innsights::Config::Report.new(Post) }
  let(:group) { Company.create(:name => 'New Company') }
  let(:user) { User.create(:name => 'New user', :company => group) }
  let(:post) { Post.create(:title => 'New post', :user => user) }
  
  
  describe '#valid?' do
    it 'says true if both the user and object are present' do
      action_user = Innsights::Actions::User.new(report, post)
      Innsights::Actions::Group.new(action_user).valid?.should == true
    end
    it 'says false if there is the user is invalid' do
      post.user_id = nil
      action_user = Innsights::Actions::User.new(report, post)
      Innsights::Actions::Group.new(action_user).valid?.should == false
    end
    it 'says false if the group is not present' do
      user.company = nil
      action_user = Innsights::Actions::User.new(report, post)
      Innsights::Actions::Group.new(action_user).valid?.should == false
    end
  end
  
  describe '#as_hash' do
    it 'returns the right group hash' do
      action_user = Innsights::Actions::User.new(report, post)
      action_group = Innsights::Actions::Group.new(action_user)
      action_group.as_hash.should == {:app_id => group.id, :display => group.to_s}
    end
  end
  
end