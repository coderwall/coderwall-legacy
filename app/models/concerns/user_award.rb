module UserAward
  extend ActiveSupport::Concern
  included do
    def award(badge)
      new_badge = self.badges.of_type(badge).first || self.badges.build(badge_class_name: badge.class.name)
    end

    def add_github_badge(badge)
      GithubBadge.new.add(badge, self.github)
    end

    def remove_github_badge(badge)
      GithubBadge.new.remove(badge, self.github)
    end

    def add_all_github_badges
      enqueue(GithubBadgeOrg, self.username, :add)
    end

    def remove_all_github_badges
      enqueue(GithubBadgeOrg, self.username, :remove)
    end

    def award_and_add_skill(badge)
      award badge
      if badge.respond_to? :skill
        add_skill(badge.skill)
      end
    end

    def assign_badges(new_badges)
      new_badge_classes = new_badges.map { |b| b.class.name }
      old_badge_classes = self.badges.map(&:badge_class_name)

      @badges_to_destroy = old_badge_classes - new_badge_classes

      new_badges.each do |badge|
        award_and_add_skill(badge)
      end
    end
  end
end