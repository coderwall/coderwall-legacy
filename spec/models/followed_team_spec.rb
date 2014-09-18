require 'rails_helper'

RSpec.describe FollowedTeam, :type => :model do
  it {is_expected.to belong_to(:team)}
  it {is_expected.to belong_to(:user)}
end

# == Schema Information
# Schema version: 20140918031936
#
# Table name: followed_teams
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  team_document_id :string(255)
#  created_at       :datetime         default(2012-03-12 21:01:09 UTC)
#  team_id          :integer
#
