class FixPgTeam < ActiveRecord::Migration
  def up
    remove_column :teams, :office_photos
    add_column :teams, :office_photos, :string, array: true, default: []
    remove_column :teams, :upcoming_events
    add_column :teams, :upcoming_events, :text, array: true, default: []
    remove_column :teams, :interview_steps
    add_column :teams, :interview_steps, :text, array: true, default: []
    remove_column :teams, :invited_emails
    add_column :teams, :invited_emails, :string, array: true, default: []
    remove_column :teams, :pending_join_requests
    add_column :teams, :pending_join_requests, :string, array: true, default: []
    add_column :teams, :state, :string, default: 'active'
    change_column :teams_locations, :description, :text
    change_column :teams_locations, :address, :text
    change_column :teams_links, :url, :text
    add_column :followed_teams, :team_id, :integer, index: true
    remove_column :teams_members,  :team_size
    remove_column :teams_members,  :badges_count
    remove_column :teams_members,  :email
    remove_column :teams_members,  :inviter_id
    remove_column :teams_members,  :name
    remove_column :teams_members,  :thumbnail_url
    remove_column :teams_members,  :username
  end
end
