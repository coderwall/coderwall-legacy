class Bear3 < LanguageBadge
  describe 'Bear 3',
           skill:             'Objective-C',
           description:       'Have at least three original repos where Objective-C is the dominant language',
           for:               'having at least three original repos where Objective-C is the dominant language.',
           image_name:        'bear3.png',
           providers:         :github,
           weight:            2,
           language_required: 'Objective-C',
           number_required:   3
end
