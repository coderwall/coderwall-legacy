module UserViewer
  extend ActiveSupport::Concern

  def viewed_by(viewer)
    epoch_now = Time.now.to_i
    Redis.current.incr(impressions_key)
    if viewer.is_a?(User)
      Redis.current.zadd(user_views_key, epoch_now, viewer.id)
      generate_event(viewer: viewer.username)
    else
      Redis.current.zadd(user_anon_views_key, epoch_now, viewer)
      count = Redis.current.zcard(user_anon_views_key)
      Redis.current.zremrangebyrank(user_anon_views_key, -(count - 100), -1) if count > 100
    end
  end

  def viewers(since=0)
    epoch_now  = Time.now.to_i
    viewer_ids = Redis.current.zrevrangebyscore(user_views_key, epoch_now, since)
    User.where(id: viewer_ids).all
  end

  def total_views(epoch_since = 0)
    if epoch_since.to_i == 0
      Redis.current.get(impressions_key).to_i
    else
      epoch_now   = Time.now.to_i
      epoch_since = epoch_since.to_i
      Redis.current.zcount(user_views_key, epoch_since, epoch_now) + Redis.current.zcount(user_anon_views_key, epoch_since, epoch_now)
    end
  end
end
