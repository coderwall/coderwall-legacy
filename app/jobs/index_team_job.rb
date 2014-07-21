class IndexTeamJob
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform(team_id)
    team = Team.find(team_id)
    team.tire.update_index
  end
end