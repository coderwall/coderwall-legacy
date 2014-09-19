class AddTeamAvatarToTeamsMember < ActiveRecord::Migration
  def change
    add_column :teams_members, :team_avatar, :string
  end
end
