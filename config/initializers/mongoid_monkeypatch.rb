if defined?(Moped)
  class Moped::BSON::ObjectId
    def to_json(*args)
      "\"#{to_s}\""
    end
  end
else
 Rails.logger.error('REMOVE Mongoid monkeypatch')
end