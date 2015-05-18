class Linkopportunitiestoteam < ActiveRecord::Migration
  def up
    puts "Opportunities before cleanup : #{Opportunity.unscoped.count}"
    Opportunity.unscoped.where(team_id: nil).find_each do |op|
      team = Team.find_by_mongo_id(op.team_document_id)
      op.update_attribute(:team, team) if team
    end
    Opportunity.where(team_id: nil).delete_all
    remove_column :opportunities, :team_document_id

    puts "Opportunities after cleanup : #{Opportunity.unscoped.count}"
  end
end
