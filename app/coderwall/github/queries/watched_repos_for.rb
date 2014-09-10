module Coderwall
  module Github
    module Queries
      class WatchedReposFor < BaseWithGithubUsername
        def self.exclude_attributes
          Coderwall::Github::Queries::Repo::REPO_ATTRIBUTES_TO_IGNORE
        end

        def fetch
          (client.watched(github_username, per_page: 100) || []).
            map(&:to_hash).
            map do |repo|
              repo.except(*self.class.exclude_attributes)
            end
        rescue Errno::ECONNREFUSED => e
          retry
        end
      end
    end
  end
end
