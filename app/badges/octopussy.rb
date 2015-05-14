class Octopussy < BadgeBase
  #
  # GITHUB_TEAM_ID_IN_PRODUCTION = '4f27193d973bf0000400029d'

  describe "Octopussy",
           skill:       'Open Source',
           description: "Have a repo followed by a member of the GitHub team",
           for:         "having a repo followed by a member of the GitHub team.",
           image_name:  'octopussy.png',
           providers:   :github,
           weight:      0

  def self.github_team
    Rails.cache.fetch("octopussy_github_team_members", expires_in: 1.day) do
      Team.find_by_name('Github').members.collect { |member| member.user.github }.compact
    end
  end

  def github_team
    self.class.github_team
  end

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('personal', 'repo', 'original') && fact.metadata && fact.metadata[:watchers]
          github_team.each do |member|
            if fact[:metadata][:watchers].include?(member)
              links << { fact.name => fact.url }
            end
          end
        end
      end
      { links: links.uniq }
    end
  end

  def award?
    reasons[:links].size >= 1
  end

  private

  def repo_followers
    user.original_repos.map do |repo|
      [repo.html_url, followers_part_of_github(repo.followers)]
    end.reject do |url, followers|
      followers.empty?
    end
  end
end
