class CreateNetworkHierarchies < ActiveRecord::Migration
  def change
    add_column :networks, :parent_id, :integer

    create_table :network_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :network_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: 'network_anc_desc_idx'

    add_index :network_hierarchies, [:descendant_id],
      name: 'network_desc_idx'

    Network.rebuild!
  end
end
