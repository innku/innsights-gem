require 'spec_helper'

describe Innsights::Actions::Group do
  before do
    Innsights.group_call = :company
  end
  let!(:report) { Innsights::Config::Report.new(Post) }
  let(:group) { Company.create(:name => 'New Company') }
  let(:user) { User.create(:name => 'New user', :company => group) }
  let(:post) { Post.create(:title => 'New post', :user => user) }

  describe 'Instantiation' do
    context 'When it receives a user' do
      let(:action_user) { Innsights::Actions::User.new(report, post)}
      let(:action_group) { Innsights::Actions::Group.new(action_user)}

      it 'Sets the user action' do
        action_group.instance_variable_get("@user_action").should == action_user
      end
      it 'Sets the user object' do
        action_group.instance_variable_get("@user").should == action_user.object
      end
      it 'Sets the group object' do
        user.stub!(:school)
        action_group.instance_variable_get("@object").should == user.company
      end
      it 'Does not set the group object when there is no group_call' do
        Innsights.stub!(:group_call){nil}
        action_group = Innsights::Actions::Group.new(action_user)
        action_group.instance_variable_get("@object").should == nil
      end
    end
    context 'When it receives a group' do
      let(:action_group) { Innsights::Actions::Group.new(user.company)}
      it 'Does not set the user_action' do
        action_group.instance_variable_get("@user_action").should == nil
      end
      it 'Does not set the user' do
        action_group.instance_variable_get("@user").should == nil
      end
      it 'Sets the object ' do
        action_group.instance_variable_get("@object").should == user.company
      end
    end

    context 'When it receives other object' do
      before do
        @company = Company.new(name: "Post Company")
        post.stub!(:company){@company}
        @action_group = Innsights::Actions::Group.new(post)
      end
      it 'Does not set the user_action' do
        @action_group.instance_variable_get("@user_action").should == nil
      end
      it 'Does not set the user' do
        @action_group.instance_variable_get("@user").should == nil
      end
      it 'Sets the object ' do
        post.should_receive(:company)
        action_group = Innsights::Actions::Group.new(post, method: :company)
        action_group.instance_variable_get("@object").should == @company
      end
    end

    context 'When it receives options' do
      it 'Calls the method on the object' do
        post.should_receive(:id)
        Innsights::Actions::Group.new(post, method: :id)
      end
      it 'Proccess the object if it is a proc' do
        c = Company.create!
        proccess = lambda{|r| c }
        proccess.should_receive(:call).with(post){c}
        group = Innsights::Actions::Group.new(post, method: proccess)
        group.instance_variable_get("@object").should == c
      end
    end
  end
  
  
  describe '#valid?' do
    context 'With a user action' do
      it 'says true if both the user and object are present' do
        action_user = Innsights::Actions::User.new(report, post)
        Innsights::Actions::Group.new(action_user).valid?.should == true
      end
      it 'says false if there is the user is invalid' do
        post,user_id = nil
        action_user = Innsights::Actions::User.new(report, post)
        Innsights::Actions::Group.new(action_user).valid?.should == false
      end
      it 'says false if the group is not present' do
        user.company = nil
        action_user = Innsights::Actions::User.new(report, post)
        Innsights::Actions::Group.new(action_user).valid?.should == false
      end
    end
    context 'Without a user action' do
      it 'says true if the group is present' do
        user.company = Company.create
        Innsights::Actions::Group.new(user.company).valid?.should == true
      end
      it 'says false if the group is not present' do 
        user.company = nil
        Innsights::Actions::Group.new(user.company).valid?.should == false
      end
    end
  end
  
  describe '#as_hash' do
    it 'returns the right group hash' do
      action_user = Innsights::Actions::User.new(report, post)
      action_group = Innsights::Actions::Group.new(action_user)
      action_group.as_hash.should == {:id => group.id, :display => group.to_s}
    end
  end
  
end
