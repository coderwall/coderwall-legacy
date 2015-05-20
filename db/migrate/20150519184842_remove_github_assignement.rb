class RemoveGithubAssignement < ActiveRecord::Migration
  def up
    drop_table :github_assignments
    remove_column :users, :gender
    remove_column :users, :redemptions
  end
end
