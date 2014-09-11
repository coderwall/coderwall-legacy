module Coderwall
  module Github
    module Queries
      module Repo
        class WatchersFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            super do
              (client.stargazers(repo_full_name, per_page: 100, accept: 'application/vnd.github.beta+json') || []).
                map(&:to_hash).
                map do |user|
                  user.select { |k| k == :login }
                end
            end
          end
        end
      end
    end
  end
end
