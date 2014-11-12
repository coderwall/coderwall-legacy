module Users
  module Github
    module Organizations
      class Follower < ActiveRecord::Base
        belongs_to :profile, :class_name => 'Users::Github::Profile'
        belongs_to :organization, :class_name => 'Users::Github::Organization'
      end
    end
  end
end

# == Schema Information
#
# Table name: users_github_organizations_followers
#
#  organization_id :integer          not null
#  profile_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
