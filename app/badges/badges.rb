class Badges
  def self.groups
    {
      ruby:       [::Mongoose, ::Ashcat, ::Mongoose3],
      c:          [::Epidexipteryx, ::Epidexipteryx3],
      erlang:     [::Locust, ::Locust3],
      clojure:    [::Narwhal, ::Narwhal3],
      dotNet:     [::Labrador, ::Labrador3],
      cPlus:      [::Trex, ::Trex3],
      node:       [::Honeybadger1, ::Honeybadger3],
      python:     [::Python, ::Python3],
      perl:       [::Velociraptor3, ::Velociraptor],
      php:        [::NephilaKomaci3, ::NephilaKomaci],
      java:       [::Komododragon, ::Komododragon3],
      objectiveC: [::Bear, ::Bear3],
      scala:      [::Platypus, ::Platypus3],
      go:         [::Beaver, ::Beaver3]
    }
  end

  def self.all
    [
      ::Beaver,

      ::Beaver3,

      ::Epidexipteryx,

      ::Epidexipteryx3,

      ::Locust,

      ::Locust3,

      ::Narwhal,

      ::Narwhal3,

      ::Ashcat,

      ::Kona,

      ::Raven,

      ::Labrador,

      ::Labrador3,

      ::Trex,

      ::Trex3,

      ::Honeybadger1,

      ::Honeybadger3,

      ::Changelogd,

      ::Bear,

      ::Bear3,

      ::Cub,

      ::Mongoose,

      ::Mongoose3,

      # ::Railscamp,

      ::Python,

      ::Python3,

      ::Charity,

      ::Forked,

      ::Forked20,

      ::Forked50,

      ::Forked100,

      ::Lemmings1000,

      ::Lemmings100,

      ::Altruist,

      ::Philanthropist,

      ::Polygamous,

      ::EarlyAdopter,

      ::Octopussy,

      ::Velociraptor3,

      ::Velociraptor,

      ::NephilaKomaci3,

      ::NephilaKomaci,

      ::Komododragon,

      ::Komododragon3,

      ::Platypus,

      ::Platypus3,

      ::Entrepreneur
    ]
  end

  def self.all_events
    [
      ::Railscamp
    ]
  end

  def self.each
    all.each do |a|
      yield a
    end
  end

end
