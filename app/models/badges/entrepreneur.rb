class Entrepreneur < BadgeBase
  describe 'Entrepreneur',
           skill:       'Entrepreneur',
           description: "Help build a product by contributing to an Assembly product",
           for:         "working on an Assembly product when your commit was accepted.",
           image_name:  'entrepreneur.png',
           weight:      3,
           providers:   :github

  def reasons
    @reasons ||= begin
      fact = user.facts.detect { |fact| fact.tagged?('assembly', 'contribution') }
      fact.name if fact
    end
  end

  def award?
    !reasons.nil?
  end

  def self.perform
    repos = %w(https://github.com/asm-helpful/helpful-web https://github.com/asm-helpful/helpful-ios https://github.com/asm-helpful/helpful-android)
    repos.each do |repo|
      owner, name = repo.split('/')[-2..-1]

      Github.new.repo_contributors(owner, name).each do |contributor|
        login = contributor[:login]
        add_contributor(repo, login, contributor[:contributions])
      end
    end
  end

  def self.add_contributor(repo_url, github_username, contributions=1)
    name = contributions <= 1 ? "Contributed one time to an Assembly product" : "Contributed #{contributions} times to an Assembly product"
    Fact.append!("#{repo_url}:#{github_username}", "github:#{github_username}", name, Time.now, repo_url, ['assembly', 'contribution'])
  end
end