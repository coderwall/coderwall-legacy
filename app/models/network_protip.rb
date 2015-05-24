class NetworkProtip < ActiveRecord::Base
  belongs_to :network, counter_cache: :protips_count_cache
  belongs_to :protip

  validates_uniqueness_of :protip_id, scope: :network_id
end
