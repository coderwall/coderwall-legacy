module Coderwall
  module Github
    module Queries
      module Repo
        class CollaboratorsFor < Coderwall::Github::Queries::Repo::Base
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
