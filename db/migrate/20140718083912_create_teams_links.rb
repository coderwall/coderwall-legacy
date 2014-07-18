class CreateTeamsLinks < ActiveRecord::Migration
  def change
    create_table :teams_links do |t|
      t.string :name
      t.string :url
      t.integer :team_id, null: false
      t.timestamps
    end
  end
end
