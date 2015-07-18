class RemoveTeamLinks < ActiveRecord::Migration
  def up
    drop_table :teams_links
    remove_column :teams,  :featured_links_title
  end
end
