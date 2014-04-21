class Polygamous < BadgeBase
  describe 'Walrus',
           skill:       'Open Source',
           description: "The walrus is no stranger to variety. Use at least 4 different languages throughout all your repos",
           for:         "using at least 4 different languages throughout your open source repos.",
           image_name:  'walrus.png',
           providers:   :github

  def reasons
    @reasons ||= begin
      facts = user.facts.select { |fact| fact.tagged?('personal', 'repo', 'original') }
      facts.collect do |fact|
        fact.metadata[:languages]
      end.flatten.uniq
    end
  end

  def award?
    reasons.size >= 4
  end

end