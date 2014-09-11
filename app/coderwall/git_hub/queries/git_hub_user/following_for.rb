module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class FollowingFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def fetch
            super { (client.following(github_username, per_page: 100) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
