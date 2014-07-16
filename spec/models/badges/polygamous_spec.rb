require 'spec_helper'

RSpec.describe Polygamous, :type => :model do

  it 'should have a name and description' do
    expect(Polygamous.name).not_to be_blank
    expect(Polygamous.description).not_to be_blank
  end

  it 'should not award the user the badge if they have less then languages with at least 200 bytes' do
    user = Fabricate(:user, github: 'mdeiters')
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['Ruby', 'PHP']})
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['C']})

    badge = Polygamous.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'should award the user the badge if they have 4 more different languages with at least 200 bytes' do
    user = Fabricate(:user, github: 'mdeiters')
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['Ruby', 'PHP']})
    Fabricate(:github_original_fact, context: user, metadata: {languages: ['C', 'Erlang']})

    badge = Polygamous.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons).to include('C', 'Erlang', 'PHP', 'Ruby')
  end

end
