class BadgeBase
  class << self
    def describe(name, attrs = {})
      @badge_options = if superclass.respond_to?(:badge_options)
                         superclass.badge_options.dup
                       else
                         {}
                       end.merge(attrs).merge(display_name: name)

      @badge_options.each do |k, v|
        method_impl = v.is_a?(Proc) ? v : lambda { v }

        singleton_class.instance_eval { define_method(k, &method_impl) }
        instance_eval { define_method(k) { |*args| self.class.send(k, *args) } }
      end
    end

    def award!(user, badge_list = Badges.all)
      badges = badge_list.map do |badge_class|
        badge_class.new(user)
      end.select do |badge|
        badge.valid? && badge.award?
      end

      badges = badges + awarded_badges(user)

      user.assign_badges(badges)
      user.save!
    end

    def awarded_badges(user)
      user.facts.select { |fact| fact.tagged?('award') }.map { |fact|
        fact.metadata[:award].constantize.new(user)
      }
    end

    def percent_earned(class_name)
      (Badge.where(badge_class_name: class_name).count / User.count.to_f * 100).round
    end

    def year
      date.year
    end
  end

  cattr_accessor :date

  describe 'Badge base',
           weight:      1,
           providers:   nil,
           image_name:  'not_implemented.png',
           description: 'Not implemented',
           for:         'Not implemented',
           image_path:  lambda { "badges/#{image_name}" },
           visible?:    true,
           date:        lambda { Date.today },
           tags:        []

  def award?
    fail 'NOT IMPLEMENTED'
  end

  def reasons
    []
  end

  attr_reader :user
  attr_reader :date
  attr_reader :tags

  def initialize(user, date = nil)
    @user = user
    @date = self.class.date = date
  end

  def valid?
    # if providers.nil?
    true
    # else
    # return !user.send(providers).blank?
    # end
  end

  def year
    @date.year
  end

  def generate_fact!(badge, username, provider)
    Fact.append!("#{url}/#{badge}:#{username}", "#{provider}:#{username}", description, date, url, (tags || []) << 'award',  award: self.class.name)
  end
end
