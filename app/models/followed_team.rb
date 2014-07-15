class FollowedTeam < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: followed_teams
#
#  id               :integer          not null, primary key
#  user_id          :integer          indexed
#  team_document_id :string(255)      indexed
#  created_at       :datetime         default(2014-02-20 22:39:11 UTC)
#
# Indexes
#
#  index_followed_teams_on_team_document_id  (team_document_id)
#  index_followed_teams_on_user_id           (user_id)
#
