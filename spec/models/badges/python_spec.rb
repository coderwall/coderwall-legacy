require 'spec_helper'

RSpec.describe Python, type: :model, skip: true do
  let(:languages) do {
    'Python' => 2_519_686,
    'Java' => 76_867
  } end
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should have a name and description' do
    expect(Python.description).not_to be_blank
  end

  it 'should not award ruby dev with one ruby repo' do
    user.build_github_facts

    badge = Python.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end

  it 'should not for a python dev' do
    languages.delete('Python')
    user.build_github_facts

    badge = Python.new(user)
    expect(badge.award?).to eq(false)
  end
end
