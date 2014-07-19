class RemoveBetaAccess < ActiveRecord::Migration
  def up
    remove_column :users, :beta_access
  end
end
