class AddTeamIdToSeizedOpportunities < ActiveRecord::Migration
  def change
    add_column :seized_opportunities, :team_id, :integer
  end
end
