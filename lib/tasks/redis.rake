namespace :redis do
  task :flush => :environment do
    $redis.flushdb
  end
end
