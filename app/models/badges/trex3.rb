class Trex3 < LanguageBadge
  describe 'T-Rex 3',
           skill:             'C',
           description:       'Have at least three original repos where C is the dominant language',
           for:               'having at least three original repos where C is the dominant language.',
           image_name:        'trex3.png',
           providers:         :github,
           language_required: 'C',
           number_required:   3,
           weight:            2
end
