module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class FollowingFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def fetch
            super { (client.following(github_username) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
