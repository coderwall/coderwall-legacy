# == Schema Information
#
# Table name: teams_accounts
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Teams::Account < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id'
end
