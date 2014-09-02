class TeamsRefreshJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform
    Team.all.each do |team|
      ProcessTeamJob.perform_async('recalculate', team.id)
    end
  end
end
