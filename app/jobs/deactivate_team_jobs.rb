class DeactivateTeamJobs < Struct.new(:id)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    team = Team.find(id)
    team.jobs.each do |job|
      job.deactivate!
    end
  end
end
