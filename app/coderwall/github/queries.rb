module Coderwall
  module Github
    module Queries
      REPO_ATTRIBUTES_TO_IGNORE = %w{open_issues description ssh_url url master_branch clone_url homepage fork pushed_at language svn_url private size forks watchers git_url created_at}

      class Base
        attr_reader :client

        def initialize(client)
          @client = client
        end

        def fetch
          raise NotImplementedError
        end
      end

      class ProfileFor < Base
        attr_reader :github_username

        def initialize(client, github_username)
          @github_username = github_username
          super(client)
        end

        def self.exclude_attributes
          %i{ followers url public_repos html_url following }
        end

        def fetch
          user = client.user(github_username)
          if user
            return user.to_hash.except(*self.class.exclude_attributes)
          else
            nil
          end
        rescue Errno::ECONNREFUSED => e
          retry
        rescue Octokit::NotFound
          user = User.find_by_github(github_username)
          user.github_failures += 1
          user.save
          {}
        end
      end

      class FollowersFor < Base
      end

      def self.followers_for(client, github_username)
        (client.followers(github_username, per_page: 100) || [])
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.following_for(client, github_username)
        (client.following(github_username, per_page: 100) || []).map(&:to_hash)
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.watched_repos_for(client, github_username)
        (client.watched(github_username, per_page: 100) || []).map(&:to_hash).map do |repo|
          repo.except(*REPO_ATTRIBUTES_TO_IGNORE)
        end
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.activities_for(github_username, times = 1)
        links = []
        times.times do |index|
          index = index + 1
          Rails.logger.debug("Github Activity: Getting page #{index} for #{github_username}")
          res = Servant.get("https://github.com/#{github_username}.atom?page=#{index}")
          doc = Nokogiri::HTML(res.to_s)
          doc.xpath('//entry').each do |entry|
            if entry.xpath('id').text.include?('WatchEvent')
              date = Time.parse(entry.xpath('published').text)
              content = Nokogiri::HTML(entry.xpath('content').text)
              links << {
                date:        date,
                link:        entry.xpath('link').first['href'],
                description: content.css('.message blockquote').text
              }
            end
          end
        end
        links
      end

      def self.repos_for(client, github_username)
        (client.repositories(github_username, per_page: 100) || []).map(&:to_hash).map do |repo|
          repo.except(*%w{master_branch clone_url ssh_url url svn_url forks})
        end
      rescue Octokit::NotFound => e
        Rails.logger.error("Unable to find repos for #{github_username}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      def self.predominant_repo_lanugage_for_link(link)
        owner, repo_name = *link.gsub(/https?:\/\/github.com\//i, '').split('/')
        repo(owner, repo_name)[:language]
      end

      def self.repo(client, owner, name)
        (client.repo("#{owner}/#{name}") || []).map(&:to_hash)
      rescue Octokit::NotFound => e
        Rails.logger.error("Unable to find repo #{owner}/#{name}")
        return {}
      rescue Errno::ECONNREFUSED => e
        retry
      end

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

      def self.repo_forks(owner, name)
        (client.forks("#{owner}/#{name}", per_page: 100) || []).map(&:to_hash).map do |user|
          user.except(*REPO_ATTRIBUTES_TO_IGNORE)
        end
      rescue Octokit::NotFound => e
        Rails.logger.error("Failed to find forks for #{owner}/#{name}")
        return []
      rescue Errno::ECONNREFUSED => e
        retry
      end

      #def self.orgs_for(github_username)
      #(client.orgs(github_username, per_page: 100) || []).map(&:to_hash)
      #rescue Errno::ECONNREFUSED => e
      #retry
      #end
    end
  end
end
