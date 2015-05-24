module ProtipNetworkable
  extend ActiveSupport::Concern

  included do
    has_many :network_protips
    has_many :networks, through: :network_protips
    after_create :update_network

  end

  def orphan?
    self.networks.empty?
  end

  private
    def update_network
      UpdateNetworkJob.perform_async(id)
    end
end
