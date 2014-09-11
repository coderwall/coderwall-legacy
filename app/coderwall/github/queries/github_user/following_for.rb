module Coderwall
  module Github
    module Queries
      module GithubUser
        class FollowingFor < Coderwall::Github::Queries::GithubUser::Base
          def fetch
            super { (client.following(github_username, per_page: 100) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
