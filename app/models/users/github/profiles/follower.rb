class Users::Github::Profiles::Follower < ActiveRecord::Base
  belongs_to :profile, :class_name => 'Users::Github::Profile'
  belongs_to :follower, :class_name => 'Users::Github::Profile'
end
