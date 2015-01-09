class AddRoleToTeamMember < ActiveRecord::Migration
  def change
    add_column :teams_members, :role, :string, default: 'member'
  end
end
