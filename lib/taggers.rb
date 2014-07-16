require 'net/http'
require 'rexml/document'
require 'uri'

class Taggers

  def self.acronyms(text)
    text.scan(/[A-Z][A-Z0-9]{2,}/).uniq
  end

  def self.tag(html = nil, url)
    html ||= Nokogiri.parse(open(url))
    title, *text = html.xpath("//title|//h1|//h2").map(&:text)
    text = (text + title).join
    tags = (YahooTagger.extract(text) + acronyms(text)).map(&:strip).uniq
    tags << title if tags.empty?
    tags
  end

  class YahooTagger
    class << self
      def extract(text)
        options = {}
        options[:context] = text
        tag_xml = retrieve(options)

        parse(tag_xml)
      end

      private
      # pass the content to YTE for term extraction
      def retrieve(options)
        options['appid'] = ENV['YAHOO_APP_KEY']
        response, data = Net::HTTP.post_form(URI.parse(ENV['YAHOO_TERM_EXTRACTION_URL']), options)
        response == Net::HTTPSuccess ? data : ""
      end

      private
      def parse(xml)
        tags = []
        doc = REXML::Document.new(xml)
        doc.elements.each("*/Result") do |result|
          tags << result.text
        end
        tags
      end
    end
  end
end