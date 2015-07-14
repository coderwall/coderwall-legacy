module UserBadge
  extend ActiveSupport::Concern

  def has_badges?
    badges.any?
  end

  def total_achievements
    badges_count
  end

  def achievement_score
    badges.collect(&:weight).sum
  end

  def achievements_unlocked_since_last_visit
    badges.where("badges.created_at > ?", last_request_at).reorder('badges.created_at ASC')
  end

  def oldest_achievement_since_last_visit
    badges.where("badges.created_at > ?", last_request_at).order('badges.created_at ASC').last
  end

  def check_achievements!(badge_list = Badges.all)
    BadgeBase.award!(self, badge_list)
    touch(:achievements_checked_at)
    save!
  end
end
