# == Schema Information
#
# Table name: network_protips
#
#  id         :integer          not null, primary key
#  network_id :integer
#  protip_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NetworkProtip < ActiveRecord::Base
  belongs_to :network, counter_cache: :protips_count_cache
  belongs_to :protip

  validates_uniqueness_of :protip_id, scope: :network_id
end
