class Honeybadger1 < LanguageBadge
  describe "Honey Badger",
           skill:             'Node.js',
           description:       "Have at least one original Node.js-specific repo",
           for:               "having at least one original Node.js-specific repo.",
           image_name:        'honeybadger.png',
           providers:         :github,
           language_required: "Node",
           number_required:   1
end