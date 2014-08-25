#TODO DELETE ME
class TeamMigratorBatchJob
  include Sidekiq::Worker

  def perform
    Team.each  do |team|
      TeamMigratorJob.perform_async(team.id.to_s)
    end
  end
end