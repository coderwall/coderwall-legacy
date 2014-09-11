module Coderwall
  module Github
    module Queries
      module Repo
        class ContributorsFor < Coderwall::Github::Queries::Repo::Base
          def fetch
            super { (client.contributors("#{repo_full_name}", false, per_page: 100) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
