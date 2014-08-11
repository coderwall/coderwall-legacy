# UserRefreshWorker
class UserRefreshWorker
  include Sidekiq::Worker

  def perform(user_id, full = false)
    user = User.find(user_id)
    return if !full && user.last_refresh_at > 3.days.ago

    # TODO: Migrate github related tasks to a github specific worker
    user.destroy_github_cache if user.github_id

    user.touch(:last_refresh_at)

    user.build_facts(full)
    user.reload.check_achievements!
    user.add_skills_for_unbadgified_facts
    user.calculate_score!
  end
end
