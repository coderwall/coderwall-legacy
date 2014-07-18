class CreatePgTeams < ActiveRecord::Migration
  def change
    create_table :pg_teams do |t|

      t.timestamps
    end
  end
end
