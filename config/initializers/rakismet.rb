Coderwall::Application.configure do
  config.rakismet.key = ENV['AKISMET_KEY']
  config.rakismet.url = ENV['AKISMET_URL']
end