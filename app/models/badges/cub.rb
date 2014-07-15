class Cub < BadgeBase
  describe 'Cub',
           skill:       'Javascript',
           description: 'Have at least one original jQuery or Prototype open source repo',
           for:         'having at least one original jQuery or Prototype open source repo.',
           image_name:  'cub.png',
           providers:   :github

  def reasons
    @reasons ||= begin
      links = []
      user.facts.select do |fact|
        fact.tagged?('personal', 'repo', 'original', 'JQuery') || fact.tagged?('personal', 'repo', 'original', 'Prototype')
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
