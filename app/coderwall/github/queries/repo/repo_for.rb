module Coderwall
  module Github
    module Queries
      module Repo
        class RepoFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            client.repo(repo_full_name).try(:to_hash)
          rescue Octokit::NotFound => e
            Rails.logger.error("Unable to find repo #{full_repo_name}")
            return {}
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
