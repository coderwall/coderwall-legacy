class Users::Github::Organizations::Follower < ActiveRecord::Base
  belongs_to :profile, :class_name => 'Users::Github::Profile'
  belongs_to :organization, :class_name => 'Users::Github::Organization'
end
