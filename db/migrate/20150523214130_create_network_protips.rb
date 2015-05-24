class CreateNetworkProtips < ActiveRecord::Migration
  def change
    create_table :network_protips do |t|
      t.integer :network_id
      t.integer :protip_id
      t.timestamps
    end

    add_column :networks, :network_tags, :citext, array: true

    Network.find_each do |n|
      tags = n.tags.pluck(:name)
      tags = tags.map(&:downcase)
      n.network_tags = tags
      n.save
    end
  end
end
