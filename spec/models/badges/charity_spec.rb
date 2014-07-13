require 'spec_helper'

RSpec.describe Charity, :type => :model do

  it 'should have a name and description' do
    expect(Charity.name).not_to be_blank
    expect(Charity.description).not_to be_blank
  end

  it 'if the project is a fork and has languages then the user should be award' do
    Fact.delete_all

    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_fork_fact, context: user)

    badge = Charity.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links].first[fact.name]).to eq(fact.url)
  end
end
