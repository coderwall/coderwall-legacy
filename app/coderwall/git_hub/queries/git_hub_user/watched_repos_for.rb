module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class WatchedReposFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def self.exclude_attributes
            Coderwall::GitHub::Queries::Repo::REPO_ATTRIBUTES_TO_IGNORE
          end

          def fetch
            super do
              (client.watched(github_username, per_page: 100) || []).
                map(&:to_hash).
                map do |repo|
                  repo.except(*self.class.exclude_attributes)
                end
            end
          end
        end
      end
    end
  end
end
