# == Schema Information
#
# Table name: teams_links
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  team_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Teams::Link < ActiveRecord::Base
  belongs_to :team, class_name: 'PgTeam',
                    foreign_key: 'team_id',
                    touch: true
end


