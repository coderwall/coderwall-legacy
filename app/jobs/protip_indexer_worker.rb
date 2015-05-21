class ProtipIndexerWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :index

  def perform(protip_id)
    begin
      protip = Protip.find(protip_id)
      Protip.index.store(protip) unless protip.user.banned?
    rescue ActiveRecord::RecordNotFound
      return
    end
  end
end
