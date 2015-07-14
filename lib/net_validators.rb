module NetValidators
  require 'net/http'
  require 'uri'

  def get_url(url_string)
    url = URI.parse url_string
    http = Net::HTTP.new url.host, url.port
    if url_string =~ /^https/
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end
    http.request(Net::HTTP::Get.new(url_string))
  end

  def valid_link?(link)
    [Net::HTTPSuccess, Net::HTTPRedirection, Net::HTTPOK].include? get_url(link).class rescue false
  end

  def correct_url(url)
    unless url.nil? or url =~ /^https?:\/\//
      "http://#{url}"
    else
      url
    end
  end
end

