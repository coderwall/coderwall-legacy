# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `github_assignments`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`badge_class_name`**  | `string(255)`      |
# **`created_at`**        | `datetime`         |
# **`github_username`**   | `string(255)`      |
# **`id`**                | `integer`          | `not null, primary key`
# **`repo_url`**          | `string(255)`      |
# **`tag`**               | `string(255)`      |
# **`updated_at`**        | `datetime`         |
#
# ### Indexes
#
# * `index_assignments_on_repo_url`:
#     * **`repo_url`**
# * `index_assignments_on_username_and_badge_class_name` (_unique_):
#     * **`github_username`**
#     * **`badge_class_name`**
# * `index_assignments_on_username_and_repo_url_and_badge_class_name` (_unique_):
#     * **`github_username`**
#     * **`repo_url`**
#     * **`tag`**
#

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
