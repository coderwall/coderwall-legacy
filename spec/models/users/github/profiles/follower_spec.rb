require 'rails_helper'

RSpec.describe Users::Github::Profiles::Follower, :type => :model do
  it {is_expected.to belong_to :profile}
  it {is_expected.to belong_to :follower}
end

# == Schema Information
#
# Table name: users_github_profiles_followers
#
#  follower_id :integer          not null
#  profile_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
