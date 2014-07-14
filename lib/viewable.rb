module Viewable
  def views_key
    "#{self.class.to_s.underscore}:#{id}:views"
  end

  def anon_views_key
    "#{self.class.to_s.underscore}:#{id}:views:anon"
  end

  def detail_views_key
    "#{self.class.to_s.underscore}:#{id}:views:detail"
  end

  def impressions_key
    "#{self.class.to_s.underscore}:#{id}:impressions"
  end

  def viewed_by(viewer)
    epoch_now = Time.now.to_i
    REDIS.incr(impressions_key)
    generate_event(viewer: viewer.username) rescue nil
    if viewer.is_a?(User)
      REDIS.zadd(views_key, epoch_now, viewer.id)
    else
      REDIS.zadd(anon_views_key, epoch_now, viewer)
      truncate_view_records
    end
  end

  def viewers(since=0)
    User.where(id: viewer_ids(since)).all
  end
  
  def viewed_by_since?(user_id, since=0)
    viewer_ids(since).include?(user_id.to_s)
  end

  def impressions
    REDIS.get(impressions_key).to_i
  end

  def total_views(since = 0)
    return impressions if since == 0

    now = Time.now.to_i
    REDIS.zcount(views_key, since, now) + REDIS.zcount(anon_views_key, since, now)
  end

  def viewer_ids(since)
    REDIS.zrevrangebyscore(views_key, Time.now.to_i, since)
  end

  def truncate_view_records
  end
end
