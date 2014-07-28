require 'spec_helper'

RSpec.describe GithubAssignment, :type => :model do

end

# == Schema Information
# Schema version: 20140728205954
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
