class NetworkProtip < ActiveRecord::Base
  belongs_to :network
  belongs_to :protip

  validates_uniqueness_of :protip_id, scope: :network_id
end
