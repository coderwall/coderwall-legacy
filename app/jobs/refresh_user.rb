class RefreshUser
  extend ResqueSupport::Basic

  @queue = 'REFRESH'

  attr_reader :username
  attr_reader :full

  def initialize(username, full=false)
    @username = username
    @full = full
  end

  def perform
    refresh!
  end

  protected
  def refresh!
    user = User.with_username(@username)

    if user.github_id
      user.destroy_github_cache
    end

    return if !@full && user.last_refresh_at > 3.days.ago

    begin
      user.build_facts(@full)
      user.reload.check_achievements!
      user.add_skills_for_unbadgified_facts

      user.calculate_score!

    ensure
      user.touch(:last_refresh_at)
      user.destroy_github_cache
    end
  end
end
