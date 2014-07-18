class CreateUsersGithubRepositoriesFollowers < ActiveRecord::Migration
  def change
    create_table :users_github_repositories_followers, id: false do |t|
      t.integer :repository_id, null: false
      t.integer :profile_id , null: false
      t.timestamps
    end
    # add_index  :users_github_repositories_followers , [:repository_id, :profile_id] , unique: true
  end
end
