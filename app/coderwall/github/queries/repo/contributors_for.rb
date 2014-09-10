module Coderwall
  module Github
    module Queries
      module Repo
        class ContributorsFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            (client.contributors("#{repo_full_name}", false, per_page: 100) || []).map(&:to_hash)
          rescue Octokit::NotFound => e
            Rails.logger.error("Failed to find contributors for #{repo_full_name}")
            return []
          rescue Octokit::InternalServerError => e
            Rails.logger.error("Failed to retrieve contributors for #{repo_full_name}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
