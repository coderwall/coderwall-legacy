preload_app true
worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout Integer(ENV['TIMEOUT'] || 45)

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(Rails.application.config.database_configuration[Rails.env])

  if defined?(Resque)
    Resque.redis = ENV['REDIS_URL']
    Rails.logger.info('Connected to Redis')
  end
end
