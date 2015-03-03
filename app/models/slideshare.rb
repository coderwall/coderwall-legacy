class Slideshare < Struct.new(:username)
  DOMAIN = "http://www.slideshare.net"

  def doc
    @doc ||= begin
      url      = "#{DOMAIN}/#{username}/presentations"
      response = RestClient.get(url, verify_ssl: false)
      Nokogiri::HTML(response)
    end
  end

  def facts
    doc.css('#slideshows ul li').collect do |presentation|
      heading = presentation.css('strong a').first
      if heading && heading[:href]
        time     = Chronic.parse(presentation.css('.stats span').first.text)
        date     = Date.parse(time.to_s)
        url      = DOMAIN + heading[:href]
        response = JSON.parse(RestClient.get("http://www.slideshare.net/api/oembed/2?url=#{url}&format=json"))
        title    = response['title']
        id       = response['slideshow_id'].to_s
        fact     = Fact.append!(id, "slideshare:#{username}", title, date, url, ['slideshare', 'presentation'])
        Importers::Protips::SlideshareImporter.import_from_fact(fact)
        fact
      end
    end.compact
  rescue RestClient::ResourceNotFound
    []
  end
end
