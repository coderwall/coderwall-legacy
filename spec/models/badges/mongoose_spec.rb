require 'spec_helper'

RSpec.describe Mongoose, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(Mongoose.description).not_to be_blank
  end

  it 'should award ruby dev with one ruby repo' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo original personal github))

    badge = Mongoose.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'should not for a dev with no repo with ruby as the dominent language' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Python repo original personal github))

    badge = Mongoose.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'doesnt award the badge if the repo is a fork' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Ruby repo fork personal github))

    badge = Mongoose.new(user)
    expect(badge.award?).to eq(false)
  end
end
