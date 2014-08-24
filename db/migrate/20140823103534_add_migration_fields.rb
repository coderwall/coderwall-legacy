class AddMigrationFields < ActiveRecord::Migration
  def up
    add_column :teams, :mongo_id, :string, unique: true
    add_column :teams_members, :state, :string, unique: true , default: 'pending'
    add_column :users, :team_id, :integer, index: true
  end
end
