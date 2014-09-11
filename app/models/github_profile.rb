class GithubProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  index({login: 1}, {unique: true, background: true})
  index({github_id: 1}, {unique: true, background: true})

  field :github_id
  field :name, type: String
  field :login, type: String
  field :company, type: String
  field :avatar_url, type: String
  field :location, type: String
  field :type, type: String

  embeds_many :followers, class_name: GithubUser.name.to_s, as: :personable

  has_and_belongs_to_many :orgs, class_name: GithubProfile.name.to_s

  ORGANIZATION = 'Organization'
  USER         = 'User'
  VALID_TYPES  = [ORGANIZATION, USER]

  def self.for_username(username)
    find_or_initialize_by(login: username).tap do |profile|
      if profile.new_record?
        logger.info "ALERT: No cached profile for user #{username}"
        profile.refresh!
      end
    end
  end

  def facts
    facts = []

    GithubRepo.where('owner.github_id' => github_id).all.each do |repo|
      if repo.has_contents?
        facts << convert_repo_into_fact(repo)
      end
    end

    GithubRepo.where(
      'contributors.github_id' => github_id,
      'owner.github_id' => { '$in' => orgs.map(&:github_id) }
    ).all.each do |repo|
      if repo.original? && repo.significant_contributions?(github_id)
        facts << convert_repo_into_fact(repo, orgrepo = true)
      end
    end
    facts << Fact.append!("github:#{login}", "github:#{login}", 'Joined GitHub', created_at, "https://github.com/#{login}", %w(github account-created))
    return facts
  end

  def convert_repo_into_fact(repo, orgrepo = false)
    tags = repo.tags + ['repo', 'github', repo.dominant_language]
    if orgrepo
      tags << 'org'
    else
      tags << 'personal'
    end
    if repo.fork?
      tags << 'fork'
    else
      tags << 'original'
    end
    metadata = {
      languages:    repo.languages_that_meet_threshold,
      original:     repo.original?,
      times_forked: repo.forks ? repo.forks.size : 0,
      watchers:     repo.followers.collect(&:login)
    }
    Fact.append!("#{repo.html_url}:#{login}", "github:#{login}", repo.name, repo.created_at, repo.html_url, tags, metadata)
  end

  def refresh!
    username = self.login

    client = Github::Coderwall::Client.instance

    profile = Coderwall::GitHub::Queries::GitHubUser::ProfileFor(client, username).fetch

    if profile
      profile.delete(:id)
    end

    github_id = User.with_username(username).github_id

    repos = Coderwall::GitHub::Queries::GitHubUser::ReposFor.new(client, username).fetch
    repos.map do |repo|
      owner, name = repo[:owner][:login], repo[:name]
      GithubRepo.for_owner_and_name(owner, name, client, repo)
    end

    update_attributes! profile.merge(
      github_id: github_id,
      followers: Coderwall::GitHub::Queries::GitHubUser::FollowersFor.new(client, username).fetch,
      following: Coderwall::GitHub::Queries::GitHubUser::FollowingFor(client, username).fetch,
      watched:   Coderwall::GitHub::Queries::GitHubUser::WatchedReposFor.new(client, username).fetch,
      orgs:      orgs,
      repos:     repos.map { |r| { id: r.id, name: r.name } }
    )
  end

  def stale?
    updated_at < 24.hours.ago
  end
end
