class SetTeamAdmins < ActiveRecord::Migration
  def up
    # doing that for teams with one member for now
    Team.where(team_size: 1).find_each do |team|
      team.members.first.update_attribute('role', 'admin')
    end
  end
end
