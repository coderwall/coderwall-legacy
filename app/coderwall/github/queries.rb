module Coderwall
  module Github
    def self.extract_repo_owner_and_name_from_url(url)
      val = {}
      val[:repo_owner], val[:repo_name] = *link.gsub(/https?:\/\/github.com\//i, '').split('/')
      val
    end

    module Queries
      # def self.orgs_for(github_username)
      #   (client.orgs(github_username, per_page: 100) || []).map(&:to_hash)
      # rescue Errno::ECONNREFUSED => e
      #   retry
      # end

      # class ActivitiesFor < BaseWithGithubUsername
      #   attr_reader :times
      #
      #   def initialize(client, github_username, times = 1)
      #     @times = times
      #     super(client, github_username)
      #   end

      #   def fetch
      #     links = []

      #     @times.times do |index|
      #       index = index + 1
      #       Rails.logger.debug("Github Activity: Getting page #{index} for #{github_username}")
      #       res = Servant.get("https://github.com/#{github_username}.atom?page=#{index}")
      #       doc = Nokogiri::HTML(res.to_s)
      #       doc.xpath('//entry').each do |entry|
      #         if entry.xpath('id').text.include?('WatchEvent')
      #           date = Time.parse(entry.xpath('published').text)
      #           content = Nokogiri::HTML(entry.xpath('content').text)
      #           links << {
      #             date:        date,
      #             link:        entry.xpath('link').first['href'],
      #             description: content.css('.message blockquote').text
      #           }
      #         end
      #       end
      #     end
      #     links
      #   end
      # end
    end
  end
end
