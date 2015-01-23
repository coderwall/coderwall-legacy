if defined?(Bugsnag)
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_API_KEY']
  end
else
  unless Rails.env.test? || Rails.env.development?
    Rails.logger.warn '[WTF WARNING] Someone deleted bugsnag and forgot the initializer'
  end
end
