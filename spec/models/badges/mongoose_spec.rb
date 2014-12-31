require 'spec_helper'

RSpec.describe Mongoose, type: :model do
  let(:languages) do {
    'Ruby' => 2_519_686,
    'JavaScript' => 6107,
    'Python' => 76_867
  } end
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(Mongoose.description).not_to be_blank
  end

  it 'should award ruby dev with one ruby repo' do
    user.build_github_facts

    badge = Mongoose.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'should not for a python dev' do
    languages.delete('Ruby')
    user.build_github_facts

    badge = Mongoose.new(user)
    expect(badge.award?).to eq(false)
  end
end
