require 'spec_helper'

describe Octopussy do
  let(:repo) { Fabricate(:github_repo) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }
  let(:pjhyett) { Fabricate(:user, github: 'pjhyett') }

  it 'should have a name and description' do
    Octopussy.name.should_not be_blank
    Octopussy.description.should_not be_blank
  end

  it 'does not award the badge if no followers work at github' do
    create_team_github = Fabricate(:team, _id: Octopussy::GITHUB_TEAM_ID_IN_PRODUCTION)
    create_team_github.add_user(pjhyett)

    random_dude = repo.followers.create! login: 'jmcneese'

    user.build_github_facts

    badge = Octopussy.new(user)
    badge.award?.should == false
  end

  it 'awards badge when repo followed by github team' do
    create_team_github = Fabricate(:team, _id: Octopussy::GITHUB_TEAM_ID_IN_PRODUCTION)
    create_team_github.add_user(pjhyett)

    github_founder = repo.followers.create! login: 'pjhyett'
    repo.save!

    user.build_github_facts

    badge = Octopussy.new(user)
    badge.award?.should == true
    badge.reasons[:links].should_not be_empty
  end

  it 'should cache github team members' do
    create_team_github = Fabricate(:team, _id: Octopussy::GITHUB_TEAM_ID_IN_PRODUCTION)
    create_team_github.add_user(pjhyett)

    Octopussy.github_team.size.should == 1

    create_team_github.add_user(Fabricate(:user, github: 'defunkt'))

    Octopussy.github_team.size.should == 1
  end

end