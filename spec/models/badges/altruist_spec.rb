require 'spec_helper'

RSpec.describe Altruist, :type => :model do

  it 'should have a name and description' do
    expect(Altruist.description).to include('20')
  end

  it 'should award user if they have 50 or more original repos with contents' do
    user = Fabricate(:user, github: 'mdeiters')

    20.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Altruist.new(user.reload)
    expect(badge.award?).to eq(true)
    expect(badge.reasons).to eq("for having shared 20 individual projects.")
  end

  it 'should not award empty repos' do
    user = Fabricate(:user, github: 'mdeiters')

    19.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Altruist.new(user.reload)
    expect(badge.award?).to eq(false)
  end
end