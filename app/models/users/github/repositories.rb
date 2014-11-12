module Users
  module Github
    module Repositories
      def self.table_name_prefix
        'users_github_repositories_'
      end
    end
  end
end
