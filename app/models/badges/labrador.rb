class Labrador < LanguageBadge
  describe "Lab",
           skill:             'C#',
           description:       "Have at least one original repo where C# is the dominant language",
           for:               "having at least one original repo where C# is the dominant language.",
           image_name:        'labrador.png',
           providers:         :github,
           language_required: "C#",
           number_required:   1

end