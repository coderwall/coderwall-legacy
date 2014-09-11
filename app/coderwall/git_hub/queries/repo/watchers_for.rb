module Coderwall
  module GitHub
    module Queries
      module Repo
        class WatchersFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super do
              (client.stargazers(repo_full_name) || []).
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
