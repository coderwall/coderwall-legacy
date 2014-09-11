module Coderwall
  module Github
    module Queries
      module Repo
        class LanguagesFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            super { client.languages(repo_full_name, per_page: 100).try(:to_hash) }
          end
        end
      end
    end
  end
end
