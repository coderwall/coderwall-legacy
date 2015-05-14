# == Schema Information
#
# Table name: seized_opportunities
#
#  id               :integer          not null, primary key
#  opportunity_id   :integer
#  opportunity_type :string(255)
#  user_id          :integer
#  team_document_id :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  team_id          :integer
#

class SeizedOpportunity < ActiveRecord::Base
  belongs_to :opportunity
  belongs_to :user
  validates_uniqueness_of :user_id, scope: :opportunity_id
end
