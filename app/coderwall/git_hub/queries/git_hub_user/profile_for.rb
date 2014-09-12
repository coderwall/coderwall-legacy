module Coderwall
  module GitHub
    module Queries
      module GitHubUser
        class ProfileFor < Coderwall::GitHub::Queries::GitHubUser::Base
          def self.exclude_attributes
            %i{ followers url public_repos html_url following }
          end

          def fetch
            user = client.user(github_username).to_attrs

            if user
              return user.except(*self.class.exclude_attributes)
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
end
