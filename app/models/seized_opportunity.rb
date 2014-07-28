class SeizedOpportunity < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20140728205954
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
#
