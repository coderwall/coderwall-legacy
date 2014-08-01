class AddGithubUniqueIndexToUser < ActiveRecord::Migration
  def change
    change_column :users, :github, :citext, index:true, unique: true
    #TODO add unique to github_id
  end
end
