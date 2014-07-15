class FollowSweeper < ActionController::Caching::Sweeper
  include ProtipsHelper
  observe Follow, FollowedTeam

  def after_save(record)
    expire_fragment_for(record)
  end

  def after_destroy(record)
    expire_fragment_for(record)
  end

  def expire_fragment_for(record)
    follower = record.respond_to?(:user_id) ? record.user_id : record.follower_id
    expire_fragment followings_fragment_cache_key(follower)
  end
end
