class Teams::Location < ActiveRecord::Base
  #Rails 3 is stupid
  belongs_to :team, class_name: 'PgTeam', foreign_key: 'team_id'
end