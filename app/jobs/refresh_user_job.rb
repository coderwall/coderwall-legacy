class RefreshUserJob
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(user_id, full=false)
    return if Rails.env.test?

    Rails.logger.info('START')

    Rails.logger.info("#{'*'*80} FIND USER #{'*'*80}")
    user = User.find(user_id)

    if user.github_id
      Rails.logger.info("#{'*'*80} DESTROY GITHUB CACHE #{'*'*80}")
      user.destroy_github_cache
    end

    unless full
      if user.last_refresh_at > 3.days.ago
        return
      end
    end

    begin
      Rails.logger.info("#{'*'*80} BUILD FACTS #{'*'*80}")
      user.build_facts
      Rails.logger.info("#{'*'*80} RELOAD CHECK ACHIEVEMENTS #{'*'*80}")
      user.reload.check_achievements!
      Rails.logger.info("#{'*'*80} ADD SKILLS FOR UNBADGIFIED FACTS #{'*'*80}")
      user.add_skills_for_unbadgified_facts

      Rails.logger.info("#{'*'*80} CALCULATE SCORE #{'*'*80}")
      user.calculate_score!
    ensure
      Rails.logger.info("#{'*'*80} TOUCH LAST REFRESH AT #{'*'*80}")
      user.touch(:last_refresh_at)
      Rails.logger.info("#{'*'*80} DESTROY GITHUB CACHE #{'*'*80}")
      user.destroy_github_cache

      Rails.logger.info('DONE')
    end
  end
end
