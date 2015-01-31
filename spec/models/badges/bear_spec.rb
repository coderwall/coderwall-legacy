require 'spec_helper'

RSpec.describe Bear, type: :model do
  it 'should have a name and description' do
    expect(Bear.description).not_to be_blank
  end

  it 'awards user bear if they have a repo tagged objective-c' do
    Fact.delete_all
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user, tags: %w(Objective-C repo original personal github))

    badge = Bear.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links].first[fact.name]).to eq(fact.url)
  end

  it 'does not award user if they dont have objective c as a dominant language' do
    Fact.delete_all
    user = Fabricate(:user)
    fact = Fabricate(:github_original_fact, context: user, tags: %w(Ruby repo original personal github))

    badge = Bear.new(user)
    expect(badge.award?).to eq(false)
  end
end
