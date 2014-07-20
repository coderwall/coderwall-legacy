class AddTeamsizeToTeamsMember < ActiveRecord::Migration
  def change
    add_column :teams_members, :team_size, :integer, default: 0
  end
end
