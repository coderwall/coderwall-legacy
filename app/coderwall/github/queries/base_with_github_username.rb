module Coderwall
  module Github
    module Queries
      class BaseWithGithubUsername < Base
        attr_reader :github_username

        def initialize(client, github_username)
          @github_username = github_username
          super(client)
        end
      end
    end
  end
end
