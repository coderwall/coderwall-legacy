require 'spec_helper'

describe Parrot do
  it "should award the badge to a user with a single talk" do
    user = Fabricate(:user)
    fact = Fabricate(:lanyrd_original_fact, context: user)

    badge = Parrot.new(user)
    badge.award?.should be_true
    badge.reasons[:links].first[fact.name].should == fact.url
  end

  it "should not award the badge to a user without any talks" do
    user = Fabricate(:user)

    badge = Parrot.new(user)
    badge.award?.should_not be_true
  end

  it "should have a name and description" do
    Parrot.name.should_not be_blank
    Parrot.description.should_not be_blank
  end
end