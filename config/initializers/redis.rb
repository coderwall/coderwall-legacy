REDIS = Redis.new(url: ENV['REDIS_URL'])
Resque.redis = REDIS

