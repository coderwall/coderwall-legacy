class Usage
  class << self
    def page_view(user_id)
      REDIS.zadd(dated_key('view'), 1, user_id)
    end

    def unique_visitors_on(date = Date.today)
      REDIS.zcount(dated_key('view', date), 1, 1000000)
    end

    def top_ten_users_today
      ids = REDIS.zrevrange(dated_key('view'), 0, 10, withscores: true)
      User.where(id: ids).all
    end

    def dated_key(keyname, date = Date.today)
      "#{keyname}:#{date.strftime('%Y-%m-%d')}"
    end
  end
end