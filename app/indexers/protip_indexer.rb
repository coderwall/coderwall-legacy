class ProtipIndexer
  def initialize(protip_or_id)
    protip_or_id = Protip.find(protip_or_id)   unless protip_or_id.is_a?(Protip)
    @protip = protip_or_id
  end

  def remove
    Protip.index.remove(@protip)
  end

  def store
    ProtipIndexerWorker.perform_async(@protip.id)
  end
end