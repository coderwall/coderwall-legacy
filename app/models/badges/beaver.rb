class Beaver < LanguageBadge
  describe 'Beaver',
           skill:             'Go',
           description:       'Have at least one original repo where go is the dominant language',
           for:               'having at least one original repo where go is the dominant language.',
           image_name:        'beaver.png',
           providers:         :github,
           language_required: 'Go',
           number_required:   1
end
