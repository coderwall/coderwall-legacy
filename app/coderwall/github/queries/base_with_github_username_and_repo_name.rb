module Coderwall
  module Github
    module Queries
      class BaseWithGithubUsernameAndRepoName < BaseWithGithubUsername
        attr_reader :repo_name

        def initialize(client, github_username, repo_name)
          @github_username = github_username
          @repo_name = repo_name

          super(client, github_username)
        end
      end
    end
  end
end
