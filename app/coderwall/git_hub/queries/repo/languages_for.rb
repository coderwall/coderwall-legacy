module Coderwall
  module GitHub
    module Queries
      module Repo
        class LanguagesFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super do
              client.languages(repo_full_name).to_attrs
            end
          end
        end
      end
    end
  end
end
