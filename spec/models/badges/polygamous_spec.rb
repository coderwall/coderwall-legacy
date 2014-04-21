require 'spec_helper'

describe Polygamous do

  it 'should have a name and description' do
    Polygamous.name.should_not be_blank
    Polygamous.description.should_not be_blank
  end

  it 'should not award the user the badge if they have less then languages with at least 200 bytes' do
    user = Fabricate(:user, github: 'mdeiters')
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['Ruby', 'PHP']})
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['C']})

    badge = Polygamous.new(user)
    badge.award?.should == false
  end

  it 'should award the user the badge if they have 4 more different languages with at least 200 bytes' do
    user = Fabricate(:user, github: 'mdeiters')
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['Ruby', 'PHP']})
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['C', 'Erlang']})

    badge = Polygamous.new(user)
    badge.award?.should == true
    badge.reasons.should include('C', 'Erlang', 'PHP', 'Ruby')
  end

end
