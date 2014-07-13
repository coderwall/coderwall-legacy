RSpec.describe Ashcat, type: :model, pending: 'the BSON document coming back is too large' do
  let(:profile) { Fabricate(:github_profile) }
  let(:contributor) { Fabricate(:user, github_id: profile.github_id, github: 'dhh') }

  it 'creates facts for each contributor' do
    VCR.use_cassette('ashcat_creates_facts_for_each_contributor') do
      Ashcat.perform

      contributor.build_github_facts

      badge = Ashcat.new(contributor)
      expect(badge.award?).to eq(true)
      expect(badge.reasons).to match(/Contributed \d+ times to Rails Core/)
    end
  end
end
