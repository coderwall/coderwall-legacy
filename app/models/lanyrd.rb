class Lanyrd < Struct.new(:username)
  HOST    = "http://lanyrd.com"
  API     = "/partners/coderwall/profile-api/"
  API_URL = "#{HOST}#{API}"

  def facts
    events.collect do |event|
      id = event[:url].sub(HOST, '') + ":#{username}"
      Fact.append!(id, "lanyrd:#{username}", event[:name], event[:date], event[:url], event[:tags])
    end
  end

  def events
    events = []
    profile[:history] && profile[:history].each do |conference|
      status = (conference[:type] == 'speaker' ? 'spoke' : 'attended')
      events << {
        url:    conference[:url],
        name:   conference[:name],
        date:   Date.parse(conference[:start_date] || conference[:end_date]),
        status: status,
        tags:   ['lanyrd', 'event', status] + topics_for(conference)
      }
    end
    events
  end

  def topics_for(conference)
    conference[:topics].collect { |topic| topic[:name] }
  end

  def profile
    @profile ||= begin
      response = RestClient.get("#{API_URL}?twitter=#{username}&view=history")
      JSON.parse(response).with_indifferent_access
    rescue RestClient::ResourceNotFound
      {}
    end
  end
end
