class CreateUsersGithubOrganizations < ActiveRecord::Migration
  def change
    create_table :users_github_organizations do |t|
      t.string :login
      t.string :company
      t.string :blog
      t.string :location
      t.string :url
      t.integer :github_id
      t.datetime :github_created_at
      t.datetime :github_updated_at
      t.timestamps
    end
  end
end
