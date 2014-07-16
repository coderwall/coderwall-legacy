class Parrot < BadgeBase
  include ActionView::Helpers::TextHelper

  describe "Parrot",
           description:    "Give at least one talk at an industry conference",
           for:            "giving at least one talk at an industry conference.",
           weight:         2,
           image_name:     "comingsoon.png",
           providers:      :twitter,
           min_talk_count: 1

  def reasons
    @reasons ||= begin
      links = []
      user.facts.each do |fact|
        if fact.tagged?('event', 'spoke')
          links << { fact.name => fact.url }
        end
      end
      { links: links }
    end
    # [ "#{pluralize(lanyrd.talk_count, 'talk')} on topics like #{lanyrd.talk_topics.to_sentence}." ]
  end

  def award?
    self.reasons[:links].size > 0
  end
end
