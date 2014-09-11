module Coderwall
  module GitHub
    module Queries
      module Repo
        class CollaboratorsFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super do
              (client.collaborators(repo_full_name, per_page: 100) || []).map(&:to_hash)
            end
          end
        end
      end
    end
  end
end
