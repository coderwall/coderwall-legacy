class RefreshUserJob
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(user_id, full=false)
    return if Rails.env.test?

    user = User.find(user_id)

    if user.github_id
      user.destroy_github_cache
    end

    unless full
      if user.last_refresh_at > 3.days.ago
        return
      end
    end

    begin
      user.build_facts
      user.reload.check_achievements!
      user.add_skills_for_unbadgified_facts

      user.calculate_score!
    ensure
      user.touch(:last_refresh_at)
      user.destroy_github_cache
    end
  end
end
