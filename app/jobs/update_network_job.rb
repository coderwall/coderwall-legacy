class UpdateNetworkJob
  #TODO move to activejob
  #OPTIMIZE
  include Sidekiq::Worker

  sidekiq_options queue: :network

  def perform(protip_id)
    protip = Protip.find(protip_id)
    tags = protip.tags
    protip.network_protips.destroy_all
    tags.each do |tag|
      networks = Network.where("? = any (network_tags)", tag).uniq
      networks.each do |network|
        protip.network_protips.find_or_create_by_network_id(network.id)
      end
    end
  end
end
