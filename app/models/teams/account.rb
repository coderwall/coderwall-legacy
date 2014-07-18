class Teams::Account < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam'
end