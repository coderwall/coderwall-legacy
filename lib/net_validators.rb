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

  class UriValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      fail(ArgumentError, 'A regular expression must be supplied as the :format option of the options hash') unless options[:format].nil? || options[:format].is_a?(Regexp)
      configuration = { message: 'is invalid or not responding', format: URI.regexp(%w(http https)) }
      configuration.update(options)

      if value =~ (configuration[:format])
        begin # check header response
          case Net::HTTP.get_response(URI.parse(value))
            when Net::HTTPSuccess, Net::HTTPRedirection then
              true
            else
              object.errors.add(attribute, configuration[:message]) and false
          end
        rescue # Recover on DNS failures..
          object.errors.add(attribute, configuration[:message]) and false
        end
      else
        object.errors.add(attribute, configuration[:message]) and false
      end
    end
  end
end
