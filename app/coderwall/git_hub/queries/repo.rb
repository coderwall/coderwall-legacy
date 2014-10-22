module Coderwall
  module GitHub
    module Queries
      module Repo
        REPO_ATTRIBUTES_TO_IGNORE = %w{open_issues description ssh_url url master_branch clone_url homepage fork pushed_at language svn_url private size forks watchers git_url created_at}

        def self.predominant_repo_language_from_url(url)
          repo_info = extract_repo_owner_and_name_from_url(url)
          predominant_repo_language_for(repo_info[:repo_owner], repo_info[:repo_name])
        end

        def self.predominant_repo_language_for(repo_name, repo_owner)
          Coderwall::GitHub::Queries::Repo::RepoFor.new(
            Coderwall::GitHub::Client.new(Coderwall::GitHub::ACCESS_TOKEN).client,
            repo_name,
            repo_owner
          ).fetch.try(:[], :language)
        end
      end
    end
  end
end
