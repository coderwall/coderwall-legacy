Github.configure do |config|
  config.client_id = ENV['GITHUB_CLIENT_ID']
  config.client_secret = ENV['GITHUB_SECRET']
end