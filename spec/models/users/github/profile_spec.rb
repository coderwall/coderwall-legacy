require 'rails_helper'
require 'vcr_helper'

RSpec.describe Users::Github::Profile, type: :model, skip: true do
  it { is_expected.to belong_to :user }
  it { is_expected.to have_many :followers }
  it { is_expected.to have_many :repositories }

  context 'creation',  vcr: { cassette_name: 'github_for seuros', record: :new_episodes } do
    it 'should get info from github' do
      user = Fabricate(:user) { github 'seuros' }
      profile = user.create_github_profile
      profile.reload

      expect(profile.name).to eq('Abdelkader Boudih')
      expect(profile.github_id).to eq(2_394_703)

    end
  end
end
