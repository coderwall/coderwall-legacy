require 'spec_helper'

RSpec.describe Cub, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  it 'should have a name and description' do
    expect(Cub.description).not_to be_nil
  end

  it 'should award the user if they have a repo tagged with JQuery' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(JQuery repo original personal github))

    badge = Cub.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'should not award if javascript is not the dominent language' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Objective-C repo original personal github))

    badge = Cub.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'should award the user if they have a repo tagged with Prototype' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Prototype repo original personal github))

    badge = Cub.new(user)
    expect(badge.award?).to eq(true)
  end

  it 'should not support forks' do
    fact = Fabricate(:github_original_fact, context: user,
      tags: %w(Prototype repo fork personal github))
      fact = Fabricate(:github_original_fact, context: user,
        tags: %w(JQuery repo fork personal github))

    user.build_github_facts

    badge = Cub.new(user)
    expect(badge.award?).to eq(false)
  end
end
