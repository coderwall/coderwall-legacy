class CreateUsersGithubOrganizationsFollowers < ActiveRecord::Migration
  def change
    create_table :users_github_organizations_followers, id: false do |t|
      t.integer :organization_id, null: false
      t.integer :profile_id , null: false
      t.timestamps
    end
    # add_index  :users_github_organizations_followers , [:organization_id, :profile_id], unique: true
  end
end
