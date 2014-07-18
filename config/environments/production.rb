Badgiy::Application.configure do
  config.threadsafe! unless $rails_rake_task
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store
  config.force_ssl = true
  config.action_controller.asset_host = ENV['CDN_ASSET_HOST']
  config.action_mailer.asset_host = ENV['CDN_ASSET_HOST']
  #config.font_assets.origin = ENV['FONT_ASSETS_ORIGIN']
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    authentication: :plain,
    address: ENV['MAILGUN_SMTP_SERVER'],
    port: ENV['MAILGUN_SMTP_PORT'],
    domain: 'coderwall.com',
    user_name: ENV['MAILGUN_SMTP_LOGIN'],
    password: ENV['MAILGUN_SMTP_PASSWORD']
  }
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.serve_static_assets = true
  config.assets.precompile = [/^[^_]/]
  config.assets.compile = true
  config.assets.compress = true
  config.assets.digest = true
  config.static_cache_control = 'public, max-age=31536000'
  config.host = ENV['HOST_DOMAIN']
  config.action_dispatch.rack_cache = true
  client = Dalli::Client.new(ENV['MEMCACHIER_SERVERS'], value_max_bytes: 10_485_760)
  config.action_dispatch.rack_cache = { metastore: client, entitystore: client }

  config.middleware.use('Rack::Attack')
end
