require 'spec_helper'

describe Charity do

  it 'should have a name and description' do
    Charity.name.should_not be_blank
    Charity.description.should_not be_blank
  end

  it 'if the project is a fork and has languages then the user should be award' do
    Fact.delete_all

    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_fork_fact, context: user)

    badge = Charity.new(user)
    badge.award?.should == true
    badge.reasons[:links].first[fact.name].should == fact.url
  end
end
