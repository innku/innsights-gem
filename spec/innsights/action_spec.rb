require 'spec_helper'

describe Innsights::Action do
  before { Innsights.group_call = :company }
  let!(:report) { Innsights::Config::Report.new(Post) }
  let(:group) { Company.create(:name => 'New Company') }
  let(:user) { User.create(:name => 'New user', :company => group) }
  let(:post) { Post.create(:title => 'New post', :user => user) }
  
  describe '#as_hash' do
    it 'works on full attributes' do
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
                                             :user => {:id => user.id, :display => user.to_s},
                                             :group => {:id => group.id, :display => group.to_s}}}
    end
    
    it 'works without company call' do
      Innsights.group_call = nil
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
                                             :user => {:id => user.id, :display => user.to_s}}}
    end
    
    it 'works without a user call' do
      report.user nil
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at }}
    end
  end
  
end
