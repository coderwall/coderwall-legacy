class IndexProtip < Struct.new(:protip_id)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    protip = Protip.find(protip_id)
    protip.tire.update_index unless protip.user.banned?
  end
end
