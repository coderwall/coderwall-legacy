CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')

  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  elsif Rails.env.development?
    config.storage = :file
    config.enable_processing = true
  else
    config.storage = :fog
    config.fog_directory = ENV['FOG_DIRECTORY']
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave::Backgrounder.configure do |c|
  c.backend = :resque
end
