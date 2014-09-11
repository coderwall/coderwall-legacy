module Coderwall
  module GitHub
    module Queries
      module Repo
        class RepoFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super { client.repo(repo_full_name).try(:to_hash) }
          end
        end
      end
    end
  end
end
