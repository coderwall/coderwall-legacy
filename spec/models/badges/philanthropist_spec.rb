require 'spec_helper'

RSpec.describe Philanthropist, type: :model do
  it 'should have a name and description' do
    expect(Philanthropist.name).not_to be_blank
    expect(Philanthropist.description).not_to be_blank
  end

  it 'should award user if they have 50 or more original repos with contents' do
    user = Fabricate(:user, github: 'mdeiters')

    50.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Philanthropist.new(user.reload)
    expect(badge.award?).to eq(true)
    expect(badge.reasons).to eq('for having shared 50 individual projects.')
  end

  it 'should not award empty repos' do
    user = Fabricate(:user, github: 'mdeiters')

    49.times do
      Fabricate(:github_original_fact, context: user)
    end

    badge = Philanthropist.new(user.reload)
    expect(badge.award?).to eq(false)
  end

end
