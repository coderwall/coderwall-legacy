Resque.before_fork do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

Resque.after_fork do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
