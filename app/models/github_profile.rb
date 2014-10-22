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

  embeds_many :followers, class_name: '::GithubUser', as: :personable

  has_and_belongs_to_many :orgs, class_name: '::GithubProfile'

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
    update_attributes!(self.class.updated_profile_for(login))
  end

  def self.updated_profile_for(github_username)
    github_id = User.with_username(github_username, :github).github_id

    client = Coderwall::GitHub::Client.instance

    profile = Coderwall::GitHub::Queries::GitHubUser::ProfileFor.new(client, github_username).fetch
    profile.delete(:id) if profile # why?

    repos = map_repos_for(client, github_username)

    followers = Coderwall::GitHub::Queries::GitHubUser::FollowersFor.new(client, github_username).fetch
    following = Coderwall::GitHub::Queries::GitHubUser::FollowingFor.new(client, github_username).fetch
    watched   = Coderwall::GitHub::Queries::GitHubUser::WatchedReposFor.new(client, github_username).fetch

    profile_params = {
      github_id: github_id,
      followers: followers,
      following: following,
      watched:   watched,
      orgs:      orgs,
      repos:     repos
    }

    profile.merge(profile_params)
  end

  def self.map_repos_for(client, github_username)
    repos = Coderwall::GitHub::Queries::GitHubUser::ReposFor.new(client, github_username).fetch
    repos.map do |repo|
      GithubRepo.for_owner_and_name(repo[:owner][:login], repo[:name], repo)
    end.map do |r|
      {
        id: r.id,
        name: r.name
      }
    end
  end

  def stale?
    updated_at < 24.hours.ago
  end
end
