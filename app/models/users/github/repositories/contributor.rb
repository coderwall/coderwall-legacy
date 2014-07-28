class Users::Github::Repositories::Contributor < ActiveRecord::Base
  belongs_to :profile, class_name: 'Users::Github::Profile'
  belongs_to :repository, :class_name => 'Users::Github::Repository'
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: users_github_repositories_contributors
#
#  repository_id :integer          not null
#  profile_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
