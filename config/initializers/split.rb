Split.redis = REDIS
Split.redis.namespace = 'split:coderwall'
Split.configure do |config|
  # config.robot_regex = //
  # config.ignore_ip_addresses << 'disable chute office' '1.2.3.4'
  # config.enabled = !Rails.env.development?
  config.db_failover = true # handle redis errors gracefully
  config.db_failover_on_db_error = proc { |error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
end

Split::Dashboard.use(Rack::Auth::Basic) do |user, password|
  user == 'coderwall' && password == ENV['BASIC_AUTH_PASSWORD']
end unless Rails.env.development?

TWITTER_SHARE_TEST = 'Left-Or-Right-Of-Protip'
