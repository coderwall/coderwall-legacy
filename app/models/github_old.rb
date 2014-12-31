#@ deprecated
class GithubOld
  @@token     = nil
  GITHUB_ROOT = "https://github.com"
  API_ROOT    = 'https://api.github.com/'

  GITHUB_REDIRECT_URL = ENV['GITHUB_REDIRECT_URL']
  GITHUB_CLIENT_ID    = ENV['GITHUB_CLIENT_ID']
  GITHUB_SECRET       = ENV['GITHUB_SECRET']

  attr_accessor :last_response, :token

  def initialize(token = nil)
    @client = Octokit::Client.new oauth_token: token, auto_traversal: true, client_id: GITHUB_CLIENT_ID, client_secret: GITHUB_SECRET
  end

  REPO_ATTRIBUTES_TO_IGNORE = %w{
    open_issues
    description
    ssh_url
    url
    master_branch
    clone_url
    homepage
    fork
    pushed_at
    language
    svn_url
    private
    size
    forks
    watchers
    git_url
    created_at
  }

  USER_ATTRIBUTES_TO_IGNORE = %w{

  }

  def profile(github_username = nil, since=Time.at(0))
    (@client.user(github_username) || []).except *%w{followers url public_repos html_url following}
  rescue Errno::ECONNREFUSED => e
    retry
  rescue Octokit::NotFound
    user                 = User.find_by_github(github_username)
    user.github_failures += 1
    user.save
    {}
  end

  def orgs_for(github_username, since=Time.at(0))
    (@client.orgs(github_username, per_page: 100) || [])
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def followers_for(github_username, since=Time.at(0))
    (@client.followers(github_username, per_page: 100) || []).map do |user|
      user.except *USER_ATTRIBUTES_TO_IGNORE
    end
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def following_for(github_username, since=Time.at(0))
    (@client.following(github_username, per_page: 100) || []).map do |user|
      user.except *USER_ATTRIBUTES_TO_IGNORE
    end
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def watched_repos_for(github_username, since=Time.at(0))
    (@client.watched(github_username, per_page: 100) || []).map do |repo|
      repo.except *REPO_ATTRIBUTES_TO_IGNORE
    end
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def activities_for(github_username, times=1)
    links = []
    times.times do |index|
      index = index + 1
      Rails.logger.debug("Github Activity: Getting page #{index} for #{github_username}")
      res = Servant.get("https://github.com/#{github_username}.atom?page=#{index}")
      doc = Nokogiri::HTML(res.to_s)
      doc.xpath('//entry').each do |entry|
        if entry.xpath('id').text.include?('WatchEvent')
          date    = Time.parse(entry.xpath('published').text)
          content = Nokogiri::HTML(entry.xpath('content').text)
          links << {
            date:        date,
            link:        entry.xpath('link').first['href'],
            description: content.css('.message blockquote').text
          }
        end
      end
    end
    links
  end

  def repos_for(github_username, since=Time.at(0))
    (@client.repositories(github_username, per_page: 100) || []).map do |repo|
      repo.except *%w{master_branch clone_url ssh_url url svn_url forks}
    end
  rescue Octokit::NotFound => e
    Rails.logger.error("Unable to find repos for #{github_username}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def predominant_repo_lanugage_for_link(link)
    owner, repo_name = *link.sub(/https?:\/\/github.com\//i, '').split('/')
    repo(owner, repo_name)[:language]
  end

  def repo(owner, name, since=Time.at(0))
    (@client.repo("#{owner}/#{name}") || [])
  rescue Octokit::NotFound => e
    Rails.logger.error("Unable to find repo #{owner}/#{name}")
    return {}
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def repo_languages(owner, name, since=Time.at(0))
    (@client.languages("#{owner}/#{name}", per_page: 100) || [])
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to find languages for #{owner}/#{name}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def repo_watchers(owner, name, since=Time.at(0))
    (@client.stargazers("#{owner}/#{name}", per_page: 100, accept: 'application/vnd.github.beta+json') || []).map do |user|
      user.select { |k| k=='login' }.with_indifferent_access
    end
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to find watchers for #{owner}/#{name}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def repo_contributors(owner, name, since=Time.at(0))
    @client.contributors("#{owner}/#{name}", false, per_page: 100) || []
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to find contributors for #{owner}/#{name}")
    return []
  rescue Octokit::InternalServerError => e
    Rails.logger.error("Failed to retrieve contributors for #{owner}/#{name}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def repo_collaborators(owner, name, since=Time.at(0))
    (@client.collaborators("#{owner}/#{name}", per_page: 100) || []).map do |user|
      user.except *USER_ATTRIBUTES_TO_IGNORE
    end
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to find collaborators for #{owner}/#{name}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end

  def repo_forks(owner, name, since=Time.at(0))
    (@client.forks("#{owner}/#{name}", per_page: 100) || []).map do |user|
      user.except *REPO_ATTRIBUTES_TO_IGNORE
    end
  rescue Octokit::NotFound => e
    Rails.logger.error("Failed to find forks for #{owner}/#{name}")
    return []
  rescue Errno::ECONNREFUSED => e
    retry
  end
end
