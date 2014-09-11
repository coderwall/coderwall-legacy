module Coderwall
  module Github
    module Queries
      module GithubUser
        class Base < Coderwall::Github::Queries::Base
          attr_reader :github_username

          def initialize(client, github_username)
            @github_username = github_username

            super(client)
          end

          def fetch
            yield if block_given?
          rescue Octokit::NotFound => e
            Rails.logger.error("Unable to find #{friendly_thing_name} #{github_username}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
