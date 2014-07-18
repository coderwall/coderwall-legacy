class Teams::Link < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam'
end