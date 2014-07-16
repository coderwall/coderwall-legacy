class Beaver3 < LanguageBadge
  describe "Beaver 3",
           skill:             'Go',
           description:       "Have at least three original repo where go is the dominant language",
           for:               "having at least three original repo where go is the dominant language.",
           image_name:        'beaver3.png',
           providers:         :github,
           language_required: "Go",
           number_required:   3,
           weight:            2
end