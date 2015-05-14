class Deleteorphantables < ActiveRecord::Migration
  def up
    drop_table :countries
    drop_table :network_experts
  end

  def down
  end
end
