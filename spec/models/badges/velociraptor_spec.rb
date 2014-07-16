require 'spec_helper'

RSpec.describe Velociraptor, :type => :model do
  let(:languages) { {
      "C" => 194738,
      "C++" => 105902,
      "Perl" => 2519686
  } }
  let(:repo) { Fabricate(:github_repo, languages: languages) }
  let(:profile) { Fabricate(:github_profile, github_id: repo.owner.github_id) }
  let(:user) { Fabricate(:user, github_id: profile.github_id) }

  it 'should have a name and description' do
    expect(Velociraptor.description).not_to be_blank
  end

  it 'should award perl dev with badge' do
    user.build_github_facts

    badge = Velociraptor.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons[:links]).not_to be_empty
  end
end
