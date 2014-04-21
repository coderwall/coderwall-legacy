class HoneybadgerBrood < BadgeBase
  describe "Honey Badger Brood",
           skill:       'Node.js',
           description: "Attend a Node.js-specific event",
           for:         "attended at least one Node.js event.",
           image_name:  'honeybadger-brood2.png',
           provides:    :github,
           weight:      2

  def award?
    false
  end
end