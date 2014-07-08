class AddLastIpToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_ip, :string
    add_column :users, :last_ua, :string
  end
end
