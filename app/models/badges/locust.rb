class Locust < LanguageBadge
  describe "Desert Locust",
           skill:             'Erlang',
           description:       "Have at least one original repo where Erlang is the dominant language",
           for:               "having at least one original repo where Erlang is the dominant language.",
           image_name:        'desertlocust.png',
           providers:         :github,
           language_required: "Erlang",
           number_required:   1

end