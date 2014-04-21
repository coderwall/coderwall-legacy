class Railsberry < BadgeBase
  describe "Railsberry",
           skill:       'Hacking',
           description: "Attended the 2012 Railsberry conference.",
           for:         "attending the 2012 Railsberry conference.",
           image_name:  'railsberry.png'

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('conference', 'attended') && fact.metadata[:name] == 'railsberry'
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end
end