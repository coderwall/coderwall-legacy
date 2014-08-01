require 'rails_helper'
require 'vcr_helper'

RSpec.describe Users::Github::Profile, :type => :model do
  it {is_expected.to belong_to :user}
  it {is_expected.to have_many :followers}
  it {is_expected.to have_many :repositories}


  context 'creation',  vcr: { :cassette_name => 'github_for seuros', :record => :new_episodes} do
    it 'should get info from github' do
      user = Fabricate(:user) { github 'seuros'}
      profile = user.create_github_profile
      profile.reload

      expect(profile.name).to eq('Abdelkader Boudih')
      expect(profile.github_id).to eq(2394703)

    end
  end
end

# == Schema Information
#
# Table name: users_github_profiles
#
#  id                :integer          not null, primary key
#  login             :citext           not null
#  name              :string(255)
#  company           :string(255)
#  location          :string(255)
#  github_id         :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  hireable          :boolean          default(FALSE)
#  followers_count   :integer          default(0)
#  following_count   :integer          default(0)
#  github_created_at :datetime
#  github_updated_at :datetime
#  spider_updated_at :datetime
#
