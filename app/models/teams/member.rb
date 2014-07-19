# == Schema Information
#
# Table name: teams_members
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  team_size  :integer          default(0)
#

class Teams::Member < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id' , counter_cache: :team_size
  belongs_to :user
end
