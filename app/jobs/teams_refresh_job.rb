class TeamsRefreshJob
  include Sidekiq::Worker

  sidekiq_options queue: :team

  def perform
    Team.all.each do |team|
      ProcessTeamJob.perform_async('recalculate', team.id)
    end
  end
end
