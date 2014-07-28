class NetworkExpert < ActiveRecord::Base
  belongs_to :network
  belongs_to :user

  DESIGNATIONS = %(mayor resident_expert)

  validates :designation, presence: true, inclusion: { in: DESIGNATIONS }
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: network_experts
#
#  id          :integer          not null, primary key
#  designation :string(255)
#  network_id  :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#
