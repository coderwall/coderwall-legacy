class ServiceResponse < Struct.new(:result, :headers)
  def to_s
    result
  end

  def json
    JSON.parse(result)
  end

  def more?
    !next_page.nil?
  end

  def requests_left
    headers[:x_ratelimit_remaining]
  end

  def next_page
    @next_page ||= begin
      if links = headers[:link]
        puts("Found multiple links: #{links}")
        links = links.split(',').collect { |parts| normalize_link(parts) }
        next_link = links.detect { |link| link[:name] == 'next' }
        next_link[:url] if next_link
      end
    end
  end

  def normalize_link(link)
    url, name = *link.strip.split(';')
    name_content = name.scan(/rel="(\w*)"/).flatten.first
    url_content = url.to_s.strip.match(/^<([\w|\W]*)>$/)[1]
    {
        name: name_content,
        url: url_content
    }
  end

end
