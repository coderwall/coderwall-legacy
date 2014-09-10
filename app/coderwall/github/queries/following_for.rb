module Coderwall
  module Github
    module Queries
      class FollowingFor < BaseWithGithubUsername
        def fetch
          (client.following(github_username, per_page: 100) || []).map(&:to_hash)
        rescue Errno::ECONNREFUSED => e
          retry
        end
      end
    end
  end
end
