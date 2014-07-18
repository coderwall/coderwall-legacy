class CreateUsersGithubProfilesFollowers < ActiveRecord::Migration
  def change
    create_table :users_github_profiles_followers, id: false do |t|
      t.integer :follower_id, null: false
      t.integer :profile_id , null: false
      t.timestamps
    end
    # add_index  :users_github_profiles_followers , [:follower_id, :profile_id], unique: true
  end
end
