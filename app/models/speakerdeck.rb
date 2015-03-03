class Speakerdeck < Struct.new(:username)
  DOMAIN = "https://speakerdeck.com"

  def debug
    doc.css('.presentations .presentation').collect(&:to_s).join('<BR>')
  end

  def doc
    @doc ||= begin
      url      = "#{DOMAIN}/u/#{username}"
      response = RestClient.get(url, verify_ssl: false)
      Nokogiri::HTML(response)
    end
  end

  def facts
    doc.css('.talks .talk').collect do |presentation|
      if id = presentation['data-id']
        info  = presentation.css('.preview_info, .talk-listing-meta')
        date  = info.css('.date').text.to_s.split('by').first.strip
        title = info.css('h3 a').text.strip
        url   = DOMAIN + info.css('h3 a').first[:href].to_s
        Fact.append!(id, "speakerdeck:#{username}", title, Date.parse(date), url, ['speakerdeck', 'presentation'])
      end
    end.compact
  rescue RestClient::ResourceNotFound
    []
  end
end