require 'rails_helper'

RSpec.describe Users::Github::Repositories::Follower, :type => :model do
 it {is_expected.to belong_to :profile}
 it {is_expected.to belong_to :repository}
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: users_github_repositories_followers
#
#  repository_id :integer          not null
#  profile_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
