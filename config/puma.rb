#!/usr/bin/env puma
require 'dotenv'
Dotenv.load
root = ENV['WEB_ROOT'] || "/home/vagrant/web/"
# The directory to operate out of.
#
# The default is the current directory.
#

# Set the environment in which the rack's app will run. The value must be a string.
#
# The default is “development”. (pass with environment variable, -e)
#
# environment "development"

# Daemonize the server into the background. Highly suggest that
# this be combined with “pidfile” and “stdout_redirect”.
#
# The default is “false”.
#
daemonize true
# daemonize false

# Store the pid of the server in the file at “path”.
#
pidfile "#{root}tmp/pids/puma.pid"

# Use “path” as the file to store the server info state. This is
# used by “pumactl” to query and control the server.
#
#state_path '/Users/justinraines/Code/flu-vaccine-map/tmp/pids/puma.state'

# Redirect STDOUT and STDERR to files specified. The 3rd parameter
# (“append”) specifies whether the output is appended, the default is
# “false”.
#
stdout_redirect "#{root}log/puma.stdout.log", "#{root}log/puma.stderr.log", true
# stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr', true

# Disable request logging.
#
# The default is “false”.
#
# quiet

# Configure “min” to be the minimum number of threads to use to answer
# requests and “max” the maximum.
#
# The default is “0, 16”.
#
threads ENV['WEB_MIN_CONCURRENCY'] || 0, ENV['WEB_MAX_CONCURRENCY'] || 16

# Bind the server to “url”. “tcp://”, “unix://” and “ssl://” are the only
# accepted protocols.
#
# The default is “tcp://0.0.0.0:9292”.
#
bind ENV['WEB_PORT'] || "tcp://0.0.0.0:3000"

# bind 'unix:///var/run/puma.sock'
# bind 'unix:///var/run/puma.sock?umask=0777'
# bind 'ssl://127.0.0.1:9292?key=path_to_key&cert=path_to_cert'

# Instead of “bind 'ssl://127.0.0.1:9292?key=path_to_key&cert=path_to_cert'” you
# can also use the “ssl_bind” option.
#
# ssl_bind '127.0.0.1', '9292', { key: path_to_key, cert: path_to_cert }

# Code to run before doing a restart. This code should
# close log files, database connections, etc.
#
# This can be called multiple times to add code each time.
#
on_restart do
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
end

# Command to use to restart puma. This should be just how to
# load puma itself (ie. 'ruby -Ilib bin/puma'), not the arguments
# to puma, as those are the same as the original process.
#
# restart_command '/u/app/lolcat/bin/restart_puma'

# === Cluster mode ===

# How many worker processes to run.
#
# The default is “0”.
#
workers ENV['WEB_WORKERS'] || 4

# Code to run when a worker boots to setup the process before booting
# the app.
#
# This can be called multiple times to add hooks.
#
on_worker_boot do
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(Rails.application.config.database_configuration[Rails.env])

  if defined?(Resque)
    Resque.redis = ENV['REDIS_URL']
    Rails.logger.info('Connected to Redis')
  end
end

# Preload app to make use of ruby 2.0 features
preload_app!

# === Puma control rack application ===

# Start the puma control rack application on “url”. This application can
# be communicated with to control the main server. Additionally, you can
# provide an authentication token, so all requests to the control server
# will need to include that token as a query parameter. This allows for
# simple authentication.
#
# Check out https://github.com/puma/puma/blob/master/lib/puma/app/status.rb
# to see what the app has available.
#
# activate_control_app 'unix:///var/run/pumactl.sock'
# activate_control_app 'unix:///var/run/pumactl.sock', { auth_token: '12345' }
# activate_control_app 'unix:///var/run/pumactl.sock', { no_token: true }