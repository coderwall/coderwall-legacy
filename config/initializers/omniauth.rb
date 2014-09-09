Rails.application.config.middleware.use OmniAuth::Builder do
  # http://rubydoc.info/gems/omniauth/OmniAuth/Strategies/Developer
  provider :developer unless Rails.env.production?

  provider :github, Coderwall::Github::CLIENT_ID, Coderwall::Github::SECRET
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  provider :linkedin, LinkedInStream::KEY, LinkedInStream::SECRET
end

OmniAuth.config.on_failure do |env|
  exception = env['omniauth.error']
  error_type = env['omniauth.error.type']
  strategy = env['omniauth.error.strategy']

  Rails.logger.error("OmniAuth #{strategy.class.name}::#{error_type}: #{exception.inspect}")

  new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{error_type}"
  [302, {'Location' => new_path, 'Content-Type' => 'text/html'}, []]
end

