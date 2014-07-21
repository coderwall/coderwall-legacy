class DeactivateTeamJobsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(id)
    team = Team.find(id)
    team.jobs.each do |job|
      job.deactivate!
    end
  end

end
