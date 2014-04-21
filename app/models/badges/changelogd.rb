!class Changelogd < BadgeBase
  describe "Changelog'd",
           skill:       'Open Source',
           description: "Have an original repo featured on the Changelog show",
           for:         "having an original repo featured on the Changelog show.",
           image_name:  'changelogd.png',
           weight:      2,
           providers:   :github

  API_URI   = "http://thechangelog.com/api/read" # tagged=episode & tagged=github
  REPO      = /([http|https]*:\/\/github\.com\/[\w | \-]*\/[\w | \-]*)/i
  USERNAME  = /github\.com\/([\w | \-]*)\/[\w | \-]*/i
  REPO_NAME = /github\.com\/[\S|\D]*\/([\S|\D]*)/i

  def reasons
    @reasons ||= begin
      links = user.facts.select do |fact|
        fact.tagged?('changedlog')
      end.collect do |fact|
        begin
          match = fact.url.match(REPO_NAME)
          { match[1] => fact.url }
        rescue
          { fact.url => fact.url }
        end
      end
      { links: links }
    end
  end

  def award?
    !reasons[:links].empty?
  end

  class << self
    def perform
      create_assignments! all_repos
    end

    def quick_refresh
      create_assignments! latest_repos
    end

    def refresh
      perform
    end

    def create_assignments!(repos)
      repos.each do |repo_url|
        match = repo_url.match(USERNAME)
        break if match.nil?
        github_username = match[1]
        Fact.append!("#{repo_url}:changedlogd", "github:#{github_username}", "Repo featured on Changelogd", Time.now, repo_url, ['repo', 'changedlog'])
      end
    end

    def latest_repos
      repos_in(API_URI).flatten.uniq
    end

    def all_repos
      repos = []
      (1...20).each do |time|
        start = ((time * 50) + 1) - 50
        repos << repos_in(API_URI + "?start=#{start}&num=50")
      end
      repos.flatten.uniq
    end

    def repos_in(url)
      puts "url #{url}"
      res = Servant.get(url)
      doc = Nokogiri::HTML(res.to_s)
      doc.xpath('//post/link-description').collect do |element|
        element.content.scan(REPO)
      end
    end
  end
end
