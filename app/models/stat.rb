class Stat < Struct.new(:name, :number, :description)
  TOTAL_ACHIEVEMENTS = [:total_achievements, 'Total Achievements']
  ORIGINAL_REPOS     = [:original_repos, 'Original Repos']
  DAYS_ON_GITHUB     = [:days_on_github, 'Days on Github']
  LANGUAGES_OWNED    = [:languages_owned, 'Languages Pwned']

  class << self
    def all
      [
        TOTAL_ACHIEVEMENTS,
        ORIGINAL_REPOS,
        DAYS_ON_GITHUB,
        LANGUAGES_OWNED
      ]
    end

    def convert(args)
      if args.is_a?(Hash)
        return Stat.new('custom', args['number'].to_i, args['description'])
      elsif args.is_a? String
        return Stat.new(args, nil, nil)
      end
    end

    def random_for_user(user)
      for_user(user).sort_by { rand }.slice(0...3).map do |name, _desc|
        Stat.new(name)
      end
    end

    def for_user(user)
      if user.github.blank?
        [TOTAL_ACHIEVEMENTS]
      else
        all
      end
    end
  end

  def dynamic?
    name.to_s != 'custom'
  end

  def dyanamicly_apply(user)
    case name.to_sym
      when TOTAL_ACHIEVEMENTS.first then
        (self.number = user.badges_count) && self.description = TOTAL_ACHIEVEMENTS.last
      when ORIGINAL_REPOS.first then
        (self.number = user.original_repos_count) && self.description = ORIGINAL_REPOS.last
      when DAYS_ON_GITHUB.first then
        (self.number = user.days_on_github) && self.description = DAYS_ON_GITHUB.last
      when LANGUAGES_OWNED.first then
        (self.number = user.languages_owned_count) && self.description = LANGUAGES_OWNED.last
    end
  end

  def show?
    true
  end

  def stat_type
    self.class.all.find { |type| type.first.to_s == name.to_s }
  end
end
