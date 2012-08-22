require 'spec_helper'

describe Innsights::Action do
  before { Innsights.group_call = :company }
  let!(:report) { Innsights::Config::Report.new(Post) }
  let(:group) { Company.create(:name => 'New Company') }
  let(:user) { User.create(:name => 'New user', :company => group) }
  let(:post) { Post.create(:title => 'New post', :user => user) }

  describe 'instantiate' do
    describe 'Group' do
      it 'Sets the group from the explicit group when specified' do
        report.report_group = group
        Innsights::Actions::Group.should_receive(:new).with(group)
        Innsights::Actions::Group.should_not_receive(:new)
                                 .with(instance_of(Innsights::Actions::User))
        Innsights::Action.new(report, post)
      end
      it 'Sets the group from the specified method called on the record' do
        report.report_group = :school
        Innsights::Actions::Group.should_receive(:new).with(post,  method: :school)
        Innsights::Action.new(report, post)

      end
      it 'Sets the group from user when there is no explicit group' do
        Innsights::Actions::Group.should_not_receive(:new).with(group)
        Innsights::Actions::Group.should_receive(:new)
                                 .with(instance_of(Innsights::Actions::User))
        Innsights::Action.new(report, post)
      end
      it 'Sets an invalid group when report explictily sets report_group to nil' do
        report.report_group = nil
        Innsights::Actions::Group.should_receive(:new).with(nil)
        Innsights::Action.new(report, post)
      end
    end
    describe 'Metrics' do
      context 'With metrics' do
        let(:report) { Innsights::Config::GenericReport.new("Mention", measure: {kg: 100, money: 200}) }

        it 'Creates the apropiate metrics' do
          Innsights::Metric.should_receive(:new).with(:kg, 100)
          Innsights::Metric.should_receive(:new).with(:money, 200)
          Innsights::Action.new(report, user)
        end
        it 'Adds the metrics to the action' do
          action = Innsights::Action.new(report, user)
          action.instance_variable_get("@metrics").size.should == 2
          action.instance_variable_get("@metrics").first.class.should == Innsights::Metric
        end
      end
      context 'Without metrics' do
        let(:report) { Innsights::Config::GenericReport.new("Mention") }

        it 'Does not create any metric' do
          Innsights::Metric.should_not_receive(:new)
          action = Innsights::Action.new(report, user)
        end
        it 'Does not update the metrics variable' do
          action = Innsights::Action.new(report, user)
          action.instance_variable_get("@metrics").should be_blank
        end
      end
    end
  end
  describe '#as_hash' do

    let(:report) { Innsights::Config::GenericReport.new("Post", measure: {kg: 100}) }
    it 'works on full attributes' do
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
        :user => {:id => user.id, :display => user.to_s},
        :group => {:id => group.id, :display => group.to_s},
        :metrics => {:kg => 100}}}
    end

    it 'works without company call' do
      Innsights.group_call = nil
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
        :user => {:id => user.id, :display => user.to_s},
        :metrics => {:kg => 100}}}
    end

    it 'works without a user call' do
      report.user nil
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
        :metrics => {:kg => 100}}}
    end

    it 'works without metrics' do
      report.instance_variable_set("@metrics", nil)
      action = Innsights::Action.new(report, post)
      action.as_hash.should == {:report => { :name => "Post", :created_at => post.created_at, 
        :user => {:id => user.id, :display => user.to_s},
        :group => {:id => group.id, :display => group.to_s}}}
    end
  end

  describe '.metrics_hash' do
    let(:report) { Innsights::Config::GenericReport.new("Mention", measure: {kg: 100, money: 200}) }
    it 'Returns the hash when there are metrics' do
      action = Innsights::Action.new(report, user)
      action.metrics_hash.should == {:kg => 100, money: 200}
    end

    it 'Returns a blank hash when there are no metrics' do
      action = Innsights::Action.new(report, user)
      action.instance_variable_set("@metrics", nil)
      action.metrics_hash.should == nil
    end
  end
end
