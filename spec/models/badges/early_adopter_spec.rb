require 'spec_helper'

RSpec.describe EarlyAdopter, type: :model do
  let(:user) { Fabricate(:user, github: 'codebender') }

  before(:each) do
    allow(ExtractGithubProfile).to receive(:perform_async)
  end

  it 'should have a name and description' do
    expect(EarlyAdopter.name).not_to be_blank
    expect(EarlyAdopter.description).not_to be_blank
  end

  it 'should award user if they joined github within 6 months of founding' do
    profile = Fabricate(:github_profile, user: user,
      github_created_at: '2008/04/14 15:53:10 -0700', github_id: 987305)

    badge = EarlyAdopter.new(user)
    expect(badge.award?).to eq(true)
    expect(badge.reasons).to eq("Created an account within GitHub's first 6 months on April 14, 2008.")
  end

  it 'should not award the user if the they joined after 6 mounts of github founding' do
    profile = Fabricate(:github_profile, user: user,
      github_created_at: '2009/04/14 15:53:10 -0700', github_id: 987305)

    badge = EarlyAdopter.new(user)
    expect(badge.award?).to eq(false)
  end

  it 'does not award the badge if the user doesnt have a github profile' do
    badge = EarlyAdopter.new(user)
    expect(badge.award?).to eq(false)
  end

end
