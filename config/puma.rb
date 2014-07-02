# Current Configuration
# =====================
# MAX_THREADS:  32
# MIN_THREADS:  8
# PUMA_WORKERS: 4
#
# half the unicorn config
#
# workers 4
# threads 2
#
# let Heroku go and do it's timeouts
#
# bringing up a legacy app try starting with workers running 1 thread until confident about thread-safety
# is threadsafe even on? <= Rails 4

port ENV['PORT'] || '3000'

workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

rackup DefaultRackup
environment ENV['RACK_ENV'] || 'development'
