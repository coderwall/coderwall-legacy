module Coderwall
  module Github
    module Queries
      class ProfileFor < BaseWithGithubUsername
        def self.exclude_attributes
          %i{ followers url public_repos html_url following }
        end

        def fetch
          user = client.user(github_username)
          if user
            return user.to_hash.except(*self.class.exclude_attributes)
          else
            nil
          end
        rescue Errno::ECONNREFUSED => e
          retry
        rescue Octokit::NotFound
          user = User.find_by_github(github_username)
          user.github_failures += 1
          user.save
          {}
        end
      end
    end
  end
end
