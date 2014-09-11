module Coderwall
  module GitHub
    module Queries
      module Repo
        class ContributorsFor < Coderwall::GitHub::Queries::Repo::Base
          def fetch
            super { (client.contributors("#{repo_full_name}", false) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
