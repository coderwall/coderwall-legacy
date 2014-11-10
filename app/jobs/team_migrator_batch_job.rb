#TODO DELETE ME
class TeamMigratorBatchJob
  include Sidekiq::Worker

  def perform
    Team.each do |team|
      begin
        TeamMigratorJob.perform_async(team.id.to_s)
      rescue => ex
        Rails.logger.error("[#{team.id.to_s}] #{ex} >>\n#{ex.backtrace.join("\n  ")}")
      end
    end
  end
end
