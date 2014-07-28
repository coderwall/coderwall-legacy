class FollowedTeam < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: followed_teams
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  team_document_id :string(255)
#  created_at       :datetime         default(2014-02-20 22:39:11 UTC)
#
