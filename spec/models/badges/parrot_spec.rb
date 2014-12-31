require 'spec_helper'

RSpec.describe Parrot, type: :model do
  it 'should award the badge to a user with a single talk' do
    user = Fabricate(:user)
    fact = Fabricate(:lanyrd_original_fact, context: user)

    badge = Parrot.new(user)
    expect(badge.award?).to be_truthy
    expect(badge.reasons[:links].first[fact.name]).to eq(fact.url)
  end

  it 'should not award the badge to a user without any talks' do
    user = Fabricate(:user)

    badge = Parrot.new(user)
    expect(badge.award?).not_to be_truthy
  end

  it 'should have a name and description' do
    expect(Parrot.name).not_to be_blank
    expect(Parrot.description).not_to be_blank
  end
end
