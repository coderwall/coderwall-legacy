class Kona < LanguageBadge
  describe "Kona",
           skill:             'CoffeeScript',
           description:       "Have at least one original repo where CoffeeScript is the dominant language",
           for:               "having at least one original repo where CoffeeScript is the dominant language.",
           image_name:        'coffee.png',
           providers:         :github,
           weight:            3,
           language_required: "CoffeeScript",
           number_required:   1

end