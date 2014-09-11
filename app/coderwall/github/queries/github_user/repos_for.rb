module Coderwall
  module Github
    module Queries
      module GithubUser
        class ReposFor < Coderwall::Github::Queries::GithubUser::Base
          def self.exclude_attributes
            %w{master_branch clone_url ssh_url url svn_url forks}
          end

          def fetch
            (client.repositories(github_username, per_page: 100) || []).
              map(&:to_hash).
              map do |repo|
                repo.except(*self.class.exclude_attributes)
              end
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
