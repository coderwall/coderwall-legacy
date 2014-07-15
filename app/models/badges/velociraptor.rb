class Velociraptor < LanguageBadge
  describe 'Velociraptor',
           skill:             'Perl',
           description:       'Have at least one original repo where Perl is the dominant language',
           for:               'having at least one original repo where Perl is the dominant language.',
           image_name:        'velociraptor.png',
           providers:         :github,
           language_required: 'Perl',
           number_required:   1
end
