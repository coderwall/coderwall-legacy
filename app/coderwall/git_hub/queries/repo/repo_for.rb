module Coderwall
  module GitHub
    module Queries
      module Repo
        class RepoFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super do
              client.repo(repo_full_name).to_attrs
            end
          end
        end
      end
    end
  end
end
