class Charity < BadgeBase
  describe 'Charity',
           skill:       'Open Source',
           description: "Fork and commit to someone's open source project in need",
           for:         "forking and commiting to someone's open source project.",
           image_name:  'charity.png',
           providers:   :github

  def reasons
    @reasons ||= begin
      links = []
      user.facts.select do |fact|
        fact.tagged?('repo', 'fork', 'personal')
      end.each do |fact|
        links << { fact.name => fact.url }
      end
      { links: links }
    end
  end

  def award?
    reasons[:links].size >= 1
  end
end
