if ENV['RAILS_ENV'] == 'production'
  require 'puma_worker_killer'

  PumaWorkerKiller.config do |config|
    # We're on PX instances which allow 6GB
    # Set the default to 4GB which allows wiggle room
    config.ram           = Integer(ENV['PWK_RAM_MB'] || 4096)
    config.frequency     = 15   # seconds
    config.percent_usage = 0.98
  end
  PumaWorkerKiller.start
end

require ::File.expand_path('../config/environment', __FILE__)

run Badgiy::Application
