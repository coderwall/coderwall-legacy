require 'spec_helper'

describe Forked do

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    Forked.name.should_not be_blank
    Forked.description.should_not be_blank
  end

  it 'should award user if a repo has been forked once' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: {times_forked: 2})

    badge = Forked.new(user)
    badge.award?.should == true
    badge.reasons[:links].first[fact.name].should == fact.url
  end

  it 'should not award user if no repo has been forked' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: {times_forked: 0})

    badge = Forked.new(user)
    badge.award?.should == false
  end

end