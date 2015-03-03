Rails.application.configure do
  require 'sidekiq/testing/inline'

  config.action_controller.perform_caching      = false
  config.action_dispatch.best_standards_support = :builtin
  config.active_support.deprecation             = :log
  config.assets.compile                         = true
  config.assets.compress                        = false
  config.assets.debug                           = false
  config.cache_classes                          = false
  config.consider_all_requests_local            = true
  config.host                                   = 'localhost:3000'
  config.serve_static_files                     = true
  config.whiny_nils                             = true
  config.eager_load                             = true
  # Mailer settings
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method       = :file
  config.action_mailer.file_settings         = { location: "#{Rails.root}/tmp/mailers" }
  config.action_mailer.asset_host            = "http://#{config.host}"

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Move cache dir's out of vagrant NFS directory
  config.cache_store                           = [:file_store,"/tmp/codewall-cache/"]
  config.assets.cache_store                    = [:file_store,"/tmp/codewall-cache/assets/"]
  Rails.application.config.sass.cache_location = "/tmp/codewall-cache/sass/"

  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
  #Rails.logger = Logger.new(STDOUT)
  #Rails.logger.level = Logger::DEBUG
end
