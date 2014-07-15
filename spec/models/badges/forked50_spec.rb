require 'spec_helper'

RSpec.describe Forked50, type: :model do
  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(Forked50.name).to include('50')
  end

  it 'should award user if a repo has been forked 100 times' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, metadata: { times_forked: 50 })

    badge = Forked50.new(user)
    expect(badge.award?).to eq(true)
  end

  it 'should not award user a repo has been forked 20 if it is a fork' do
    user = Fabricate(:user, github: 'mdeiters')
    fact = Fabricate(:github_original_fact, context: user, tags: %w(Ruby repo original fork github), metadata: { times_forked: 20 })

    badge = Forked20.new(user)
    expect(badge.award?).to eq(false)
  end

end
