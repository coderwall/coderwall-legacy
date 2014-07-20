class CreateTeamsMembers < ActiveRecord::Migration
  def change
    create_table :teams_members do |t|
      t.integer :team_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
