class CleanupSeizedOpportunities < ActiveRecord::Migration
  def up
    remove_column :seized_opportunities, :team_id
    remove_column :seized_opportunities, :opportunity_type
    remove_column :seized_opportunities, :team_document_id
    drop_table :available_coupons
    drop_table :purchased_bundles
    drop_table :tokens
    drop_table :sessions
    drop_table :highlights
  end
end
