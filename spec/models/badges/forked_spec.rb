require 'spec_helper'

RSpec.describe Forked, type: :model, skip: true do

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(Forked.name).not_to be_blank
    expect(Forked.description).not_to be_blank
  end

  it 'should award user if a repo has been forked once' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: { times_forked: 2 })

    badge = Forked.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links].first[fact.name]).to eq(fact.url)
  end

  it 'should not award user if no repo has been forked' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: { times_forked: 0 })

    badge = Forked.new(user)
    expect(badge.award?).to eq(false)
  end

end
