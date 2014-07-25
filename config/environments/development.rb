Coderwall::Application.configure do
  config.threadsafe! unless $rails_rake_task

  config.action_controller.perform_caching = false
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.assets.compile = true
  config.assets.compress = false
  config.assets.debug = false
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.host = 'localhost:3000'
  config.serve_static_assets = true
  config.whiny_nils = true
  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Move cache dir's out of vagrant NFS directory
  config.cache_store = [:file_store,"/tmp/codewall-cache/"]
  config.assets.cache_store = [:file_store,"/tmp/codewall-cache/assets/"]
  Rails.application.config.sass.cache_location = "/tmp/codewall-cache/sass/"
  
  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
end
