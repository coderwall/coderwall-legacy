class Forked < BadgeBase
  describe 'Forked',
           skill:        'Open Source',
           description:  'Have a project valued enough to be forked by someone else',
           for:          'having a project valued enough to be forked by someone else.',
           image_name:   lambda { "forked#{times_forked}.png" },
           providers:    :github,
           skip_forks:   false,
           times_forked: 1

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?(*tag_list) && times_forked_for(fact) >= times_forked
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
  end

  def times_forked_for(fact)
    if fact[:metadata] && fact[:metadata][:times_forked]
      fact[:metadata][:times_forked].to_i
    else
      0
    end
  end

  def tag_list
    if skip_forks
      %w(personal repo original)
    else
      %w(personal repo)
    end
  end

  def award?
    reasons[:links].size >= 1
  end
end
