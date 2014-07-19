# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

#Rename to Team when Mongodb is dropped
class PgTeam < ActiveRecord::Base
  self.table_name = 'teams'
  #TODO add inverse_of
  has_one :account, class_name: 'Teams::Account', foreign_key: 'team_id', dependent: :destroy

  has_many :members, class_name: 'Teams::Member', foreign_key: 'team_id', dependent: :destroy
  has_many :links, class_name: 'Teams::Link', foreign_key: 'team_id', dependent: :destroy
  has_many :locations, class_name: 'Teams::Location', foreign_key: 'team_id', dependent: :destroy
  has_many :jobs, class_name: 'Opportunity', foreign_key: 'team_id', dependent: :destroy


end
