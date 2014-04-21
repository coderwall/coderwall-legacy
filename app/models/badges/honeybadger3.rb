class Honeybadger3 < Honeybadger1
  describe "Honey Badger 3",
           skill:             'Node.js',
           description:       "Have at least three Node.js specific repos",
           for:               "having at least three Node.js specific repos.",
           image_name:        'honeybadger3.png',
           providers:         :github,
           weight:            2,
           language_required: "Node",
           number_required:   3
end