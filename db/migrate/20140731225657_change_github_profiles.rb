class ChangeGithubProfiles < ActiveRecord::Migration
  def up
    change_column :users_github_profiles, :github_id, :integer, null: true
    change_column :users_github_profiles, :login, :citext, null: false
    add_column :users_github_profiles, :hireable, :boolean, default: false
    add_column :users_github_profiles, :followers_count, :integer, default: 0
    add_column :users_github_profiles, :following_count, :integer, default: 0
    add_column :users_github_profiles, :github_created_at, :datetime
    add_column :users_github_profiles, :github_updated_at, :datetime
    add_column :users_github_profiles, :spider_updated_at, :datetime
  end
end
