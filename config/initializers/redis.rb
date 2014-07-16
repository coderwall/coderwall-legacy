REDIS = Redis.connect(url: ENV['REDIS_URL'])
Resque.redis = REDIS

