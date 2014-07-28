class AddGithubOrganizationNameToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :github_organization_name, :string
  end
end
