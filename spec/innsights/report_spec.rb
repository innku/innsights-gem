require 'spec_helper'

describe Innsights::Report do
  before do 
    class Foo
      def some_method;end;
    end
  end
  let(:user)   { User.create}
  let(:report) { Innsights::Report.new("Mention", user: user) }

  describe '#initialize' do
    it 'Sets the action name' do
      report.name.should == "Mention"
    end
    it 'Sets the user' do
      report.user.object.should == user
    end
    it 'Can instantiate the action name' do
      r = Innsights::Report.new("Mention")
      r.name.should == "Mention"
    end
    it 'Can instantiate with action name and user' do
      r = Innsights::Report.new("Mention", user: user)
      r.name.should == "Mention"
      r.user.object.should == user
    end
    it 'Can instantiate action name and an option hash' do
      time = Time.now
      r = Innsights::Report.new("Mention", user: user, created_at: time)
      r.name.should == "Mention"
      r.user.object.should == user
      r.created_at.should == time
    end
    it 'Can add a group' do
      company = Company.new
      r = Innsights::Report.new("Mention", group: company)
      r.resources[0].object.should == company
    end
    it 'Can add many groups' do
      company = Company.new
      r = Innsights::Report.new("Mention", resources: {company: company,
                                                       company2: company})
      r.resources[0].object.should == company
    end
    it 'Can add a created_at' do
      time = Time.now
      r = Innsights::Report.new("Mention", created_at: time)
      r.created_at.should == time
    end
    it 'Can add a single metic' do
      r = Innsights::Report.new("Mention", measure: {kg: 100})
      r.metrics.should == {kg: 100}
    end
    it 'Can add multiple metrics' do
      r = Innsights::Report.new("Mention", measure: {kg: 100, money: 200})
      r.metrics.should == {kg: 100, money: 200}
    end
    it 'Does not modify unspecified options' do
      r = Innsights::Report.new("Mention", created_at: Time.now, user: user)
      r.user.object.should == user
    end
  end
  describe '.run' do
    before do
      Innsights.client = Innsights::Client.new("url.com", 'subdoamin', '1234', 'test') 
      Innsights.client.stub(:report).and_return { true }
    end
    context 'With a report user' do
      it 'It users the report_user as the record' do
        Innsights.client.should_receive(:report).with(report.to_hash)
        report.run
      end
    end
  end
  describe '.to_hash' do
    it 'shows the report hash representation with group fallback' do
      c = Company.create(name: "Innku")
      r = Innsights::Report.new("Mention", user: user,
                                group: c, source: "non-follower",
                                measure: {kg: 100, money: 200})
      r.to_hash.should == {report: {name: "Mention",
                                    created_at: r.created_at,
                                    user: {id: user.id, display: user.to_s},
                                    resources: {group: {id: c.id, display: c.to_s}},
                                    metrics: {kg: 100, money: 200}}}
    end
    it 'shows the report hash representation' do
      c = Company.create(name: "Innku")
      r = Innsights::Report.new("Mention", user: user,
                                resources: {company: c}, source: "non-follower",
                                measure: {kg: 100, money: 200})
      r.to_hash.should == {report: {name: "Mention",
                                    created_at: r.created_at,
                                    user: {id: user.id, display: user.to_s},
                                    resources: {company: {id: c.id, display: c.to_s}},
                                    metrics: {kg: 100, money: 200}}}
    end
  end
end
