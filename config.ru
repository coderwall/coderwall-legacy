if ENV['RAILS_ENV'] == 'production'
  require 'puma_worker_killer'

  PumaWorkerKiller.config do |config|
    config.ram           = 260 # mb
    config.frequency     = 15   # seconds
    config.percent_usage = 0.98
  end
  PumaWorkerKiller.start
end

require ::File.expand_path('../config/environment', __FILE__)

use Rack::Deflater

run Badgiy::Application
