class ChangeTeamSlugToCitext < ActiveRecord::Migration
  def change
    change_column :teams, :slug, :citext, null: false, index: true , unique: true
  end
end
