require 'spec_helper'

RSpec.describe NephilaKomaci, type: :model do
  let(:languages) do {
    'PHP' => 2_519_686,
    'Python' => 76_867
  } end
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  before :all do
    Fact.delete_all
  end

  it 'should have a name and description' do
    expect(NephilaKomaci.description).not_to be_blank
  end

  it 'should award php dev with badge' do
    user.build_github_facts

    badge = NephilaKomaci.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

end
