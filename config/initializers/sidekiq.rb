# https://devcenter.heroku.com/articles/forked-pg-connections#sidekiq
redis_url = (ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL'])
sidekiq_redis_url = redis_url.to_s + '/2'  # Use third database

Sidekiq.configure_server do |config|
  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=25"
    ActiveRecord::Base.establish_connection
  end
  if redis_url
    config.redis = { url: sidekiq_redis_url }
  end
end

Sidekiq.configure_client do |config|
  if redis_url
    config.redis = { url: sidekiq_redis_url }
  end
end

require 'sidekiq/web'
Sidekiq::Web.app_url = '/admin'
