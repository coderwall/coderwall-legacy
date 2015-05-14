class Changelogd < BadgeBase
  describe "Changelog'd",
           skill:       'Open Source',
           description: "Have an original repo featured on the Changelog show",
           for:         "having an original repo featured on the Changelog show.",
           image_name:  'changelogd.png',
           weight:      2,
           providers:   :github

  def award?
    false
  end

end
