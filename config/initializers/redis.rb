REDIS = Redis.new(url: ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL'])
