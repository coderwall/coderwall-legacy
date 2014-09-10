module Coderwall
  module Github
    module Queries
      module Repo
        class LanguagesFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            client.languages(repo_full_name, per_page: 100).try(:to_hash)
          rescue Octokit::NotFound => e
            Rails.logger.error("Failed to find languages for #{repo_full_name}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
