class ProtipIndexerWorker
  include Sidekiq::Worker

  sidekiq_options :queue =>  :high

  def perform(protip_id)
    protip = Protip.find(protip_id)
    Protip.index.store(protip) unless protip.user.banned?
  end
end
