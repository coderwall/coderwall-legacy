class AddFieldsToTeamsMembers < ActiveRecord::Migration
  def change
    add_column :teams,         :team_size,     :integer
    add_column :teams_members, :badges_count,  :integer
    add_column :teams_members, :email,         :string
    add_column :teams_members, :inviter_id,    :integer
    add_column :teams_members, :name,          :string
    add_column :teams_members, :thumbnail_url, :string
    add_column :teams_members, :username,      :string
  end
end
