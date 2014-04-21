class Hackathon < BadgeBase
  describe "Hackathon",
           description: "Participated in a hackathon.",
           for:         "participating in a hackathon.",
           image_name:  'hackathon.png'

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('hackathon', 'inperson') && !fact.tagged?('university')
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end
end