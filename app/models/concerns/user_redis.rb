module UserRedis
  extend ActiveSupport::Concern

  def seen(feature_name)
    Redis.current.SADD("user:seen:#{feature_name}", self.id.to_s)
  end

  def seen?(feature_name)
    Redis.current.SISMEMBER("user:seen:#{feature_name}", self.id.to_s) == 1 #true
  end
end

