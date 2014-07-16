class Narwhal < LanguageBadge
  describe "Narwhal",
           skill:             'Clojure',
           description:       "Have at least one original repo where Clojure is the dominant language",
           for:               "having at least one original repo where Clojure is the dominant language.",
           image_name:        'narwhal.png',
           providers:         :github,
           language_required: "Clojure",
           number_required:   1,
           weight:            2

end