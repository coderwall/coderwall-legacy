require 'spec_helper'

describe EarlyAdopter do
  it 'should have a name and description' do
    EarlyAdopter.name.should_not be_blank
    EarlyAdopter.description.should_not be_blank
  end

  it 'should award user if they joined github within 6 months of founding' do
    profile = Fabricate(:github_profile, created_at: '2008/04/14 15:53:10 -0700')
    user = Fabricate(:user, github_id: profile.github_id)

    user.build_github_facts

    badge = EarlyAdopter.new(user)
    badge.award?.should == true
    badge.reasons.should == "Created an account within GitHub's first 6 months on April 14, 2008."
  end

  it 'should not award the user if the they joined after 6 mounts of github founding' do
    profile = Fabricate(:github_profile, created_at: '2009/04/14 15:53:10 -0700')
    user = Fabricate(:user, github_id: profile.github_id)

    user.build_github_facts

    badge = EarlyAdopter.new(user)
    badge.award?.should == false
  end

end