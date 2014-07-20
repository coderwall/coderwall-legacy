# == Schema Information
#
# Table name: users_github_organizations_followers
#
#  organization_id :integer          not null
#  profile_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Users::Github::Organizations::Follower, :type => :model do
  it {is_expected.to belong_to :profile}
  it {is_expected.to belong_to :organization}
end
