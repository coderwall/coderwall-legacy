class AddTeamIdToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :team_id, :integer
  end
end
