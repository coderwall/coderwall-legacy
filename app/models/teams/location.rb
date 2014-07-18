class Teams::Location < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam'
end