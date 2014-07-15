class Lemmings100 < BadgeBase
  describe 'Lemmings 100',
           skill:              'API Design',
           description:        'Write something great enough to have at least 100 watchers of the project',
           for:                'writing something great enough to have at least 100 people following it.',
           image_name:         '100lemming.png',
           providers:          :github,
           required_followers: 100,
           weight:             3

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('personal', 'repo', 'original') && times_watched(fact) >= required_followers
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end

  def times_watched(fact)
    if fact[:metadata] && fact[:metadata][:watchers]
      fact[:metadata][:watchers].size
    else
      0
    end
  end

  def award?
    reasons[:links].size >= 1
  end
end
