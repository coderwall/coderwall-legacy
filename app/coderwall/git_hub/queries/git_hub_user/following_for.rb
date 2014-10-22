module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class FollowingFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def fetch
            super do
              (client.following(github_username) || []).map(&:to_attrs)
            end
          end
        end
      end
    end
  end
end
