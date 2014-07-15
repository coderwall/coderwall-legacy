class Velociraptor3 < LanguageBadge
  describe 'Velociraptor 3',
           skill:             'Perl',
           description:       'Have at least three original repos where Perl is the dominant language',
           for:               'having at least three original repos where Perl is the dominant language',
           image_name:        'velociraptor3.png',
           providers:         :github,
           language_required: 'Perl',
           number_required:   3,
           weight:            2
end
