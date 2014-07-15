class Locust3 < LanguageBadge
  describe 'Desert Locust 3',
           skill:             'Erlang',
           description:       'Have at least three original repos where Erlang is the dominant language',
           for:               'having at least three original repos where Erlang is the dominant language.',
           image_name:        'desertlocust3.png',
           providers:         :github,
           language_required: 'Erlang',
           number_required:   3,
           weight:            2
end
