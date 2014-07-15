class HackathonStanford < BadgeBase
  describe 'Stanford Hackathon',
           skill:       'Hacking',
           description: "Participated in Stanford's premier Hackathon, organized by the ACM, SVI Hackspace and BASES.",
           for:         "participating in Stanford's premier Hackathon, organized by the ACM, SVI Hackspace and BASES.",
           image_name:  'hackathonStanford.png'

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('hackathon', 'university') && fact.metadata[:school] == 'Stanford'
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end
end
