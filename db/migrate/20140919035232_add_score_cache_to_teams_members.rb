class AddScoreCacheToTeamsMembers < ActiveRecord::Migration
  def change
    add_column :teams_members, :score_cache, :float
  end
end
