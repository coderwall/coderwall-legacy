module Coderwall
  module Github
    module Queries
      def self.repo_languages(client, owner, name)
        (client.languages("#{owner}/#{name}", per_page: 100) || []).map(&:to_hash)
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find languages for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.repo_watchers(client, owner, name)
        (client.stargazers("#{owner}/#{name}", per_page: 100, accept: 'application/vnd.github.beta+json') || []).map(&:to_hash).map do |user|
          user.select { |k| k=='login' }.with_indifferent_access
        end
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find watchers for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.repo_contributors(client, owner, name)
        (client.contributors("#{owner}/#{name}", false, per_page: 100) || []).map(&:to_hash)
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find contributors for #{owner}/#{name}")
        return []
      rescue Octokit::InternalServerError => e
        Rails.logger.error("Failed to retrieve contributors for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.repo_collaborators(client, owner, name)
        (client.collaborators("#{owner}/#{name}", per_page: 100) || []).map(&:to_hash)
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find collaborators for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.repo_forks(client, owner, name)
        (client.forks("#{owner}/#{name}", per_page: 100) || []).map(&:to_hash).map do |user|
          user.except(*REPO_ATTRIBUTES_TO_IGNORE)
        end
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find forks for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      REPO_ATTRIBUTES_TO_IGNORE = %w{open_issues description ssh_url url master_branch clone_url homepage fork pushed_at language svn_url private size forks watchers git_url created_at}

      # class PredominantRepoLanugageForLink
      #   def fetch(link)
      #     owner, repo_name = *link.gsub(/https?:\/\/github.com\//i, '').split('/')
      #     repo(owner, repo_name)[:language]
      #   end
      # end

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
