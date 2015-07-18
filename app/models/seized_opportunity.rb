# == Schema Information
#
# Table name: seized_opportunities
#
#  id             :integer          not null, primary key
#  opportunity_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class SeizedOpportunity < ActiveRecord::Base
  belongs_to :opportunity
  belongs_to :user
  validates_presence_of :opportunity_id, :user_id
  validates_uniqueness_of :user_id, scope: :opportunity_id
end
