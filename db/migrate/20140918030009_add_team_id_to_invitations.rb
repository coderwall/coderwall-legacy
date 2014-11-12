class AddTeamIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :team_id, :integer
  end
end
