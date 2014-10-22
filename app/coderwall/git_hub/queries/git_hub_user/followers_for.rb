module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class FollowersFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def fetch
            super { (client.followers(github_username) || []).map(&:to_attrs) }
          end
        end
      end
    end
  end
end
