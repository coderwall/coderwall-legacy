require 'spec_helper'

describe Lemmings1000 do

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    Lemmings1000.name.should_not be_blank
    Lemmings1000.description.should_not be_blank
  end

  it 'should not award users with less then 1000 followers' do
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user)

    badge = Lemmings1000.new(user)
    badge.award?.should == false
  end

  it 'should award the user the badge if any of their projects have over 1000 followers' do
    user = Fabricate(:user)
    watchers = []
    1000.times do
      watchers << Faker::Internet.user_name
    end
    fact = Fabricate(:github_original_fact, context: user, metadata: {watchers: watchers})

    badge = Lemmings1000.new(user)
    badge.award?.should == true
    badge.reasons[:links].first[fact.name].should == fact.url
  end

end