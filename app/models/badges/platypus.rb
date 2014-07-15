class Platypus < LanguageBadge
  describe 'Platypus',
           skill:             'Scala',
           description:       'Have at least one original repo where scala is the dominant language',
           for:               'having at least one original repo where scala is the dominant language.',
           image_name:        'platypus.png',
           providers:         :github,
           language_required: 'Scala',
           number_required:   1,
           weight:            2
end
