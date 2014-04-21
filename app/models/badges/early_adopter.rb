class EarlyAdopter < BadgeBase
  describe "Opabinia",
           skill:       'Open Source',
           description: "Started social coding on GitHub within 6 months of its first signs of life",
           for:         "starting social coding on GitHub within 6 months of its first signs of life.",
           image_name:  'earlyadopter.png',
           providers:   :github,
           weight:      2

  FOUNDING_DATE = Date.parse('Oct 19, 2007')

  def reasons
    found = user.facts.detect do |fact|
      fact.tagged?('github', 'account-created')
    end
    if found && found.relevant_on <= FOUNDING_DATE + 6.months
      "Created an account within GitHub's first 6 months on #{found.relevant_on.to_date.to_s(:long).to_s.capitalize}."
    else
      nil
    end
  end

  def award?
    !reasons.blank?
  end
end