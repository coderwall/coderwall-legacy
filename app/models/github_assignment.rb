class GithubAssignment < ActiveRecord::Base
  scope :badge_assignments, where(repo_url: nil)

  def self.for_repo(url)
    where(repo_url: url)
  end

  def self.tagged(tag)
    where(tag: tag)
  end

  def self.for_github_username(github_username)
    return empty = [] if github_username.nil?
    where(['UPPER(github_username) = ?', github_username.upcase])
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: github_assignments
#
#  id               :integer          not null, primary key
#  github_username  :string(255)      indexed => [badge_class_name], indexed => [repo_url, tag]
#  repo_url         :string(255)      indexed, indexed => [github_username, tag]
#  tag              :string(255)      indexed => [github_username, repo_url]
#  created_at       :datetime
#  updated_at       :datetime
#  badge_class_name :string(255)      indexed => [github_username]
#
# Indexes
#
#  index_assignments_on_repo_url                                    (repo_url)
#  index_assignments_on_username_and_badge_class_name               (github_username,badge_class_name) UNIQUE
#  index_assignments_on_username_and_repo_url_and_badge_class_name  (github_username,repo_url,tag) UNIQUE
#
