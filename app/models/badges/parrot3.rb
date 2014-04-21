class Parrot3 < Parrot
  describe "Parrot 3",
           description:    "Give at least three talks at an industry conference",
           for:            "giving at least three talks at an industry conference.",
           weight:         3,
           image_name:     "comingsoon.png",
           providers:      :twitter,
           min_talk_count: 3

end