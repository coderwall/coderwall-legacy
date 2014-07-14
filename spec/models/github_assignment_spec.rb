# == Schema Information
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
# Indexes
#
#  index_assignments_on_repo_url                                    (repo_url)
#  index_assignments_on_username_and_badge_class_name               (github_username,badge_class_name) UNIQUE
#  index_assignments_on_username_and_repo_url_and_badge_class_name  (github_username,repo_url,tag) UNIQUE
#

require 'spec_helper'

RSpec.describe GithubAssignment, :type => :model do

end
