module Coderwall
  module Github
    module Queries
      module Repo
        class Base < Coderwall::Github::Queries::Base
          attr_reader :repo_owner, :repo_name

          def repo_full_name
            @repo_full_name ||= "#{repo_owner}/#{repo_name}".freeze
          end

          def initialize(client, repo_owner, repo_name)
            @repo_owner = repo_owner
            @repo_name = repo_name

            super(client)
          end

          def fetch
            yield if block_given?
          rescue Octokit::NotFound => e
            Rails.logger.error("Failed to find #{friendly_thing_name} #{repo_full_name}")
            return []
          rescue Errno::ECONNREFUSED => e
            retry
          end
        end
      end
    end
  end
end
