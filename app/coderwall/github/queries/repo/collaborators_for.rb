module Coderwall
  module Github
    module Queries
      module Repo
        class CollaboratorsFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            (client.collaborators(repo_full_name, per_page: 100) || []).map(&:to_hash)
          rescue Octokit::NotFound => e
            Rails.logger.error("Failed to find collaborators for #{repo_full_name}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
