# TODO, rename to Teams::Follower
class FollowedTeam < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam'
  belongs_to :user
end

# == Schema Information
#
# Table name: followed_teams
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  team_document_id :string(255)
#  created_at       :datetime         default(2012-03-12 21:01:09 UTC)
#  team_id          :integer
#
