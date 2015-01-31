require 'spec_helper'

RSpec.describe Octopussy, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }
  let(:pjhyett) { Fabricate(:user, github: 'pjhyett') }

  it 'should have a name and description' do
    expect(Octopussy.name).not_to be_blank
    expect(Octopussy.description).not_to be_blank
  end

  it 'does not award the badge if no followers work at github' do
    create_team_github = Fabricate(:team, name: "Github")
    create_team_github.add_member(pjhyett)

    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo original personal github),
      metadata: { watchers: 'rubysolos' })

    badge = Octopussy.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'awards badge when repo followed by github team' do
    create_team_github = Fabricate(:team, name: "Github")
    create_team_github.add_member(pjhyett)

    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo original personal github),
      metadata: { watchers: 'pjhyett' })

    badge = Octopussy.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'does not award forked repos' do
    create_team_github = Fabricate(:team, name: "Github")
    create_team_github.add_member(pjhyett)

    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo fork personal github),
      metadata: { watchers: 'pjhyett' })

    badge = Octopussy.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'should cache github team members' do
    create_team_github = Fabricate(:team, name: "Github")
    create_team_github.add_member(pjhyett)

    expect(Octopussy.github_team.size).to eq(1)

    create_team_github.add_member(Fabricate(:user, github: 'defunkt'))

    expect(Octopussy.github_team.size).to eq(1)
  end

end
