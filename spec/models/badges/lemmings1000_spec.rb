require 'spec_helper'

RSpec.describe Lemmings1000, :type => :model do

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(Lemmings1000.name).not_to be_blank
    expect(Lemmings1000.description).not_to be_blank
  end

  it 'should not award users with less then 1000 followers' do
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user)

    badge = Lemmings1000.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'should award the user the badge if any of their projects have over 1000 followers' do
    user = Fabricate(:user)
    watchers = []
    1000.times do
      watchers << Faker::Internet.user_name
    end
    fact = Fabricate(:github_original_fact, context: user, metadata: {watchers: watchers})

    badge = Lemmings1000.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links].first[fact.name]).to eq(fact.url)
  end

end