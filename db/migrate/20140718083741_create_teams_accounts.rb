class CreateTeamsAccounts < ActiveRecord::Migration
  def change
    create_table :teams_accounts do |t|
      t.integer :team_id, null: false
      t.timestamps
    end
  end
end
