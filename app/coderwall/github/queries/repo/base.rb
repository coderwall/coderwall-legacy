module Coderwall
  module Github
    module Queries
      module Repo
        class Base < Coderwall::Github::Queries::Base
          attr_reader :repo_owner, :repo_name
          attr_reader :github_username

          def repo_full_name
            @repo_full_name ||= "#{repo_owner}/#{repo_name}".freeze
          end

          def initialize(client, repo_owner, repo_name)
            @github_username = @repo_owner = repo_owner
            @repo_name = repo_name

            super(client)
          end
        end
      end
    end
  end
end
