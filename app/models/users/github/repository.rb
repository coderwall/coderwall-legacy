class Users::Github::Repository < ActiveRecord::Base
  has_many :followers, :class_name => 'Users::Github::Repositories::Follower' , dependent: :delete_all
  has_many :contributors, :class_name => 'Users::Github::Repositories::Contributor' , dependent: :delete_all
  belongs_to :organization, :class_name => 'Users::Github::Organization'
  belongs_to :owner, :class_name => 'Users::Github::Profile'
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: users_github_repositories
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  description                 :text
#  full_name                   :string(255)
#  homepage                    :string(255)
#  fork                        :boolean          default(FALSE)
#  forks_count                 :integer          default(0)
#  forks_count_updated_at      :datetime         default(2014-07-23 03:14:37 UTC)
#  stargazers_count            :integer          default(0)
#  stargazers_count_updated_at :datetime         default(2014-07-23 03:14:37 UTC)
#  language                    :string(255)
#  followers_count             :integer          default(0), not null
#  github_id                   :integer          not null
#  owner_id                    :integer
#  organization_id             :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
