class AddTeamSizeToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :team_size, :integer
  end
end
