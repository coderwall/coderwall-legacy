class AddTeamBannerToTeamsMember < ActiveRecord::Migration
  def change
    add_column :teams_members, :team_banner, :string
  end
end
