class WrocLover < BadgeBase
  describe 'wroc_love.rb',
           skill:       'Ruby',
           description: 'Attended the 2012 wroc_love.rb ruby conference.',
           for:         'attending the 2012 wroc_love.rb ruby conference.',
           image_name:  'wrocloverb.png'

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('conference', 'attended') && fact.metadata[:name] == 'WrocLove'
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end
end
