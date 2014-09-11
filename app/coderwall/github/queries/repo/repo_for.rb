module Coderwall
  module Github
    module Queries
      module Repo
        class RepoFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            super { client.repo(repo_full_name).try(:to_hash) }
          end
        end
      end
    end
  end
end
