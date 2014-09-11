module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class FollowersFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def fetch
            super { (client.followers(github_username, per_page: 100) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end