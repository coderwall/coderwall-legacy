module Coderwall
  module Github
    module Queries
      class RepoFor < BaseWithGithubUsernameAndRepoName
        def fetch
          full_repo_name = "#{github_username}/#{repo_name}"
          client.repo(full_repo_name).to_hash
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
