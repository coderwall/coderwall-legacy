Coderwall::Application.configure do
  config.cache_store = :redis_store, "#{ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']}/#{ENV['REDIS_CACHE_STORE'] || 3}"
end
