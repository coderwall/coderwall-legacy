class HackathonCmu < BadgeBase
  describe 'CMU Hackathon',
           skill:       'Hacking',
           description: "Participated in CMU's Hackathon, organized by ScottyLabs.",
           for:         "participating in CMU's Hackathon, organized by ScottyLabs.",
           image_name:  'hackathonCMU.png'

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('hackathon', 'university') && fact.metadata[:school] == 'Carnegie Mellon'
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end
end
