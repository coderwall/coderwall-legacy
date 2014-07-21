class RefreshUserJob
  include Sidekiq::Worker

  def perform(username, full=false)
    user = User.find_by_username(username)

    if user.github_id
      user.destroy_github_cache
    end

    return if !full && user.last_refresh_at > 3.days.ago

    begin
      user.build_facts(full)
      user.reload.check_achievements!
      user.add_skills_for_unbadgified_facts

      user.calculate_score!

    ensure
      user.touch(:last_refresh_at)
      user.destroy_github_cache
    end
  end
end
