module UserGithub
  extend ActiveSupport::Concern

  def clear_github!
    self.github_id        = nil
    self.github           = nil
    self.github_token     = nil
    self.joined_github_on = nil
    self.github_failures  = 0
    save!
  end

  def build_github_proptips_fast
    repos = followed_repos(since=2.months.ago)
    repos.each do |repo|
      Importers::Protips::GithubImporter.import_from_follows(repo.description, repo.link, repo.date, self)
    end
  end

  def build_repo_followed_activity!(refresh=false)
    Redis.current.zremrangebyrank(followed_repo_key, 0, Time.now.to_i) if refresh
    epoch_now  = Time.now.to_i
    first_time = refresh || Redis.current.zcount(followed_repo_key, 0, epoch_now) <= 0
    links      = GithubOld.new.activities_for(self.github, (first_time ? 20 : 1))
    links.each do |link|
      link[:user_id] = self.id
      Redis.current.zadd(followed_repo_key, link[:date].to_i, link.to_json)
      Importers::Protips::GithubImporter.import_from_follows(link[:description], link[:link], link[:date], self)
    end
  rescue RestClient::ResourceNotFound
    []
  end
end
