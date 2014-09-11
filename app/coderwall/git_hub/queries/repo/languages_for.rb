module Coderwall
  module GitHub
    module Queries
      module Repo
        class LanguagesFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super { client.languages(repo_full_name).try(:to_hash) }
          end
        end
      end
    end
  end
end
