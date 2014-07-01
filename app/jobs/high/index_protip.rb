class IndexProtip < Struct.new(:protip_id)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    protip = Protip.find(protip_id)
    Coderwall::Search::IndexProtip.run(protip)
  end
end
