class Users::Github::Profile < ActiveRecord::Base
  belongs_to :user
  has_many :followers, class_name: 'Users::Github::Profiles::Follower' , foreign_key: :follower_id  , dependent: :delete_all
  has_many :repositories, :class_name => 'Users::Github::Repository' , foreign_key: :owner_id
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: users_github_profiles
#
#  id         :integer          not null, primary key
#  login      :string(255)
#  name       :string(255)
#  company    :string(255)
#  location   :string(255)
#  github_id  :integer          not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
