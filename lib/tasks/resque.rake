require 'resque/tasks'
require 'resque/scheduler/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  # http://stackoverflow.com/questions/2611747/rails-resque-workers-fail-with-pgerror-server-closed-the-connection-unexpectedly
  Resque.after_fork do |worker|
    ActiveRecord::Base.establish_connection
  end
end

task "resque:scheduler_setup" => :environment

namespace :resque do
  desc "Clear pending tasks"
  task :clear => :environment do
    queues = Resque.queues
    queues.each do |queue_name|
      puts "Clearing #{queue_name}..."
      Resque.redis.del "queue:#{queue_name}"
    end

    puts "Clearing delayed..." # in case of scheduler - doesn't break if no scheduler module is installed
    Resque.redis.keys("delayed:*").each do |key|
      Resque.redis.del "#{key}"
    end
    Resque.redis.del "delayed_queue_schedule"

    puts "Clearing stats..."
    Resque.redis.set "stat:failed", 0
    Resque.redis.set "stat:processed", 0
  end
end