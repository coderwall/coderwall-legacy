Tire.configure do
  url ENV['ELASTICSEARCH_URL']
end

Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL']