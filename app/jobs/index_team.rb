class IndexTeam < Struct.new(:team_id)
  extend ResqueSupport::Basic

  @queue = 'HIGH'

  def perform
    team = Team.find(team_id)
    team.tire.update_index
  end
end
