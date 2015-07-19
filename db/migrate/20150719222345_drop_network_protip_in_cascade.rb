class DropNetworkProtipInCascade < ActiveRecord::Migration
  def up
    remove_foreign_key 'network_protips', 'networks'
    remove_foreign_key 'network_protips', 'protips'
    add_foreign_key 'network_protips', 'networks', name: 'network_protips_network_id_fk', dependent: :delete
    add_foreign_key 'network_protips', 'protips', name: 'network_protips_protip_id_fk', dependent: :delete
  end
end
