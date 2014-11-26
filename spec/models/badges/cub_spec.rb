require 'spec_helper'

RSpec.describe Cub, type: :model, skip: true do
  let(:languages) do {
    'JavaScript' => 111_435
  } end
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should have a name and description' do
    expect(Cub.description).not_to be_nil
  end

  it 'should award the user if they have a repo tagged with JQuery' do
    repo.add_tag('JQuery')
    repo.save!

    user.build_github_facts

    badge = Cub.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'should not award if repo when readme contains text and is less then 90 javascript' do
    languages['JavaScript'] = 230_486
    languages['Ruby'] = 20_364

    user.build_github_facts

    badge = Cub.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'should award the user if they have a repo tagged with Prototype' do
    repo.add_tag('Prototype')
    repo.save!

    user.build_github_facts

    badge = Cub.new(user)
    expect(badge.award?).to eq(true)
  end

  it 'should not support forks' do
    repo.fork = true
    repo.save!

    user.build_github_facts

    badge = Cub.new(user)
    expect(badge.award?).to eq(false)
  end
end
