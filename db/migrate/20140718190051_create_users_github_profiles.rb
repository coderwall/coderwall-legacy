class CreateUsersGithubProfiles < ActiveRecord::Migration
  def change
    create_table :users_github_profiles do |t|
      t.string :login
      t.string :name
      t.string :company
      t.string :location
      t.integer :github_id, index: true, null: false, unique: true
      t.integer :user_id
      t.timestamps
    end
  end
end
