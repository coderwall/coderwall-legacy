require 'spec_helper'

describe Bear do
  it 'should have a name and description' do
    Bear.description.should_not be_blank
  end

  it 'awards user bear if they have a repo tagged objective-c' do
    Fact.delete_all
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user, tags: ['Objective-C', 'repo', 'original', 'personal', 'github'])

    badge = Bear.new(user)
    badge.award?.should == true
    badge.reasons[:links].first[fact.name].should == fact.url
  end

  it 'does not award user if they dont have objective c as a dominant language' do
    Fact.delete_all
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user, tags: ['Ruby', 'repo', 'original', 'personal', 'github'])

    badge = Bear.new(user)
    badge.award?.should == false
  end
end
