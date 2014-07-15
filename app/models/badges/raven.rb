class Raven < LanguageBadge
  describe 'Raven',
           skill:             'Shell',
           description:       'Have at least one original repo where some form of shell script is the dominant language',
           for:               'having at least one original repo where some form of shell script is the dominant language.',
           image_name:        'raven.png',
           providers:         :github,
           language_required: 'Shell',
           number_required:   1
end
