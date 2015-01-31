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
    if user.github_profile && user.github_profile.github_created_at <= FOUNDING_DATE + 6.months
      "Created an account within GitHub's first 6 months on #{user.github_profile.github_created_at.to_date.to_s(:long).to_s.capitalize}."
    else
      nil
    end
  end

  def award?
    !reasons.blank?
  end
end
