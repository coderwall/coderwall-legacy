module Coderwall
  module Github
    module Queries
      module GithubUser
        class FollowersFor < Coderwall::Github::Queries::GithubUser::Base
          def fetch
            super { (client.followers(github_username, per_page: 100) || []).map(&:to_hash) }
          end
        end
      end
    end
  end
end
