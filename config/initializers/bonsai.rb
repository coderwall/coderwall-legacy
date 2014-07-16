if ENV['ELASTICSEARCH_URL']
  Tire.configure { logger $stdout, :level => (ENV['ELASTICSEARCH_LOG_LEVEL'] || 'debug') }
  Tire.configure do
    url ENV['ELASTICSEARCH_URL']
  end
  BONSAI_INDEX_NAME = ENV['ELASTICSEARCH_INDEX']
elsif ENV['BONSAI_INDEX_URL']
  Tire.configure { logger $stdout, :level => (ENV['ELASTICSEARCH_LOG_LEVEL'] || 'debug') }
  Tire.configure do
    url "http://index.bonsai.io"
  end
  BONSAI_INDEX_NAME = ENV['BONSAI_INDEX_URL'][/[^\/]+$/]
else
  Tire.configure { logger Rails.root + "log/tire_#{Rails.env}.log" }
  app_name = Rails.application.class.parent_name.underscore.dasherize
  BONSAI_INDEX_NAME = "#{app_name}-#{Rails.env}"
end