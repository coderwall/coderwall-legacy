class Teams::Member < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id' , counter_cache: :team_size
  belongs_to :user
end