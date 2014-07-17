Badgiy::Application.configure do
  config.cache_store = :redis_store, "#{ENV['REDIS_URL']}/#{ENV['REDIS_CACHE_STORE'] || 2}"
end
