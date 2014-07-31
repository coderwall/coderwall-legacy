class RemoveUselessFieldsFromPgTeam < ActiveRecord::Migration
  def up
    remove_column :teams, :admins
    remove_column :teams, :editors
  end
end
