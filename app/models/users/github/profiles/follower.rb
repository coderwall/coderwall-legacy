module Users
  module Github
    module Profiles
      class Follower < ActiveRecord::Base
        belongs_to :profile, :class_name => 'Users::Github::Profile'
        belongs_to :follower, :class_name => 'Users::Github::Profile'
      end
    end
  end
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
