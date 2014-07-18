class CreateUsersGithubRepositories < ActiveRecord::Migration
  def change
    create_table :users_github_repositories do |t|
      t.string :name
      t.text :description
      t.string :full_name
      t.string :homepage
      t.boolean :fork , default: false
      t.integer :forks_count, default: 0
      #TODO remigrate default in rails 4. rails 3 schema dumper is stupid
      t.datetime :forks_count_updated_at, default:'NOW()'
      t.integer :stargazers_count, default: 0
      t.datetime :stargazers_count_updated_at, default:'NOW()'
      t.string :language
      t.integer :followers_count, default: 0, null: false
      t.integer :github_id, index: true, null: false, unique: true
      t.integer :owner_id, index: true
      t.integer :organization_id, index: true
      t.timestamps

    end
  end
end
