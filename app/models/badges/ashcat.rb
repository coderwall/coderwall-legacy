class Ashcat < BadgeBase
  describe 'Ashcat',
           skill:       'Ruby on Rails',
           description: 'Make Ruby on Rails better for everyone by getting a commit accepted',
           for:         'making Ruby on Rails better for everyone when your commit was accepted.',
           image_name:  'moongoose-rails.png',
           weight:      3,
           providers:   :github

  def reasons
    @reasons ||= begin
      fact = user.facts.find { |fact| fact.tagged?('rails', 'contribution') }
      fact.name if fact
    end
  end

  def award?
    !reasons.nil?
  end

  def self.perform
    Github.new.repo_contributors('rails', 'rails').each do |contributor|
      login = contributor[:login]
      add_contributor(login, contributor[:contributions])
    end
  end

  def self.add_contributor(github_username, contributions = 1)
    repo_url = 'https://github.com/rails/rails'
    name     = contributions <= 1 ? 'Contributed one time to Rails Core' : "Contributed #{contributions} times to Rails Core"
    Fact.append!("#{repo_url}:#{github_username}", "github:#{github_username}", name, Time.now, repo_url, %w(rails contribution))
  end
end
