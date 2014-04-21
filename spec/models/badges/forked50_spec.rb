require 'spec_helper'

describe Forked50 do
  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    Forked50.name.should include('50')
  end

  it 'should award user if a repo has been forked 100 times' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: {times_forked: 50})

    badge = Forked50.new(user)
    badge.award?.should == true
  end

  it 'should not award user a repo has been forked 20 if it is a fork' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, tags: ['Ruby', 'repo', 'original', 'fork', 'github'], metadata: {times_forked: 20})

    badge = Forked20.new(user)
    badge.award?.should == false
  end

end
