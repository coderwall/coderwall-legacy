module Coderwall
  module Facts
    class GitHub

      attr_reader :github_id, :login, :github_username, :user

      def initialize(user)
        @user = user
      end

      def skip?
        user.github.present? && user.github_failures == 0
      end

      def calculate
        facts = []

        GithubRepo.where('owner.github_id' => user.github_id).all.each do |repo|
          if repo.has_contents?
            facts << convert_repo_into_fact(repo)
          end
        end

        GithubRepo.where(
          'contributors.github_id' => user.github_id,
          'owner.github_id' => { '$in' => u.orgs.map(&:github_id) }
        ).
        all.
        each do |repo|
          if repo.original? && repo.significant_contributions?(user.github_id)
            facts << convert_repo_into_fact(repo, orgrepo = true)
          end
        end

        facts << Fact.append!(
          "github:#{login}",
          "github:#{login}",
          'Joined GitHub',
          user.github_profile.created_at,
          "https://github.com/#{login}",
          %w(github account-created)
        )

        return facts
      end

      def convert_repo_into_fact(repo, orgrepo = false)
        tags = repo.tags
        tags += %w(repo github)
        tags << repo.dominant_language
        tags << if orgrepo ? 'org' : 'personal'
        tags <<  repo.fork? ? 'fork' : 'original'

        metadata = {
          languages:    repo.languages_that_meet_threshold,
          original:     repo.original?,
          times_forked: repo.forks ? repo.forks.size : 0,
          watchers:     repo.followers.collect(&:login)
        }

        Fact.append!(
          "#{repo.html_url}:#{user.github}",
          "github:#{user.github}",
          repo.name,
          repo.created_at,
          repo.html_url,
          tags,
          metadata
        )
      end

      def identity
        "github:#{user.github}"
      end

      def self.friendly_thing_name
        @friendly_thing_name ||= self.name.underscore.split('/').last.gsub('_', ' ')
      end
    end
  end
end
