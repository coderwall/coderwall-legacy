class Teams::Member < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam'
  belongs_to :user
end