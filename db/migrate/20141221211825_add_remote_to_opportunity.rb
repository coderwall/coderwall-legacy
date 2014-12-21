class AddRemoteToOpportunity < ActiveRecord::Migration
  def change
    add_column :opportunities, :remote, :boolean
  end
end
