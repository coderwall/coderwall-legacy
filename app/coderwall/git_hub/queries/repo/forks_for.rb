module Coderwall
  module GitHub
    module Queries
      module Repo
        class ForksFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super do
              (client.forks(repo_full_name, per_page: 100) || []).
                map(&:to_hash).
                map do |user|
                  user.except(*REPO_ATTRIBUTES_TO_IGNORE)
                end
            end
          end
        end
      end
    end
  end
end
