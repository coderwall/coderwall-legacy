module Coderwall
  module Github
    module Queries
      module Repo
        class ForksFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            (client.forks(repo_full_name, per_page: 100) || []).
              map(&:to_hash).
              map do |user|
                user.except(*REPO_ATTRIBUTES_TO_IGNORE)
              end
          rescue Octokit::NotFound => e
            Rails.logger.error("Failed to find forks for #{repo_full_name}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
