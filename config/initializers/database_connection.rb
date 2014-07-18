# https://devcenter.heroku.com/articles/concurrency-and-database-connections#connection-pool
#
# Recommendation is to set pool equal to MAX_THREADS
#
Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] || Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool']              = ENV['DB_POOL']      || ENV['MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end
