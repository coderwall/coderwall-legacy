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
    where(["UPPER(github_username) = ?", github_username.upcase])
  end

end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: github_assignments
#
#  id               :integer          not null, primary key
#  github_username  :string(255)
#  repo_url         :string(255)
#  tag              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  badge_class_name :string(255)
#
