class Users::Github::Repository < ActiveRecord::Base
  has_many :followers, :class_name => 'Users::Github::Repositories::Follower' , dependent: :delete_all
  has_many :contributors, :class_name => 'Users::Github::Repositories::Contributor' , dependent: :delete_all
  belongs_to :organization, :class_name => 'Users::Github::Organization'
  belongs_to :owner, :class_name => 'Users::Github::Profile'
end
