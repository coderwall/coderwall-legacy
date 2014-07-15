class Badge < ActiveRecord::Base
  include ResqueSupport::Basic

  belongs_to :user, counter_cache: :badges_count, touch: true
  validates_uniqueness_of :badge_class_name, scope: :user_id
  after_create :generate_event

  scope :of_type, ->(badge) { where(badge_class_name: badge.class.name) }

  class << self
    def rename(old_class_name, new_class_name)
      Badge.where(badge_class_name: old_class_name).map { |badge| badge.update_attribute(:badge_class_name, new_class_name) }
      Fact.where('metadata LIKE ?', "%#{old_class_name}%").each do |fact|
        if fact.metadata[:award] == old_class_name
          fact.metadata[:award] = new_class_name
        end
        fact.save
      end
      ApiAccess.where('awards LIKE ?', "%#{old_class_name}%").each do |api_access|
        if api_access.awards.delete(old_class_name)
          api_access.awards << new_class_name
        end
        api_access.save
      end
    end
  end

  def display_name
    badge_class.display_name
  end

  def image_path
    badge_class.image_path
  end

  def for
    badge_class.for
  end

  def visible?
    badge_class.visible?
  end

  def tokenized_skill_name
    @tokenized_skill_name ||= begin
      if badge_class.respond_to?(:skill)
        Skill.tokenize(badge_class.skill)
      else
        ''
      end
    end
  end

  def next
    Badge.where(user_id: user_id).where("id > ?", self.id).order('created_at ASC').first
  end

  def friendly_percent_earned
    if percent_earned <= 0
      "Less than 1%"
    else
      "Only #{percent_earned}%"
    end
  end

  def percent_earned
    badge_class.percent_earned(badge_class_name)
  end

  def description
    badge_class.description
  end

  def weight
    badge_class.weight
  end

  def fact
    self.user.facts.find { |fact| fact.metadata[:award] == badge_class_name }
  end

  def badge_class
    @badge_class ||= badge_class_name.constantize
  end

  def generate_event
    enqueue(GenerateEvent, self.event_type, Audience.user_reach(self.user.id), self.to_event_hash, 30.minutes)
    enqueue(GenerateEvent, self.event_type, Audience.user(self.user.id), self.to_event_hash, 30.minutes)
  end

  def to_event_hash
    { achievement: { name:     self.display_name, description: (self.try(:for) || self.try(:description)), percentage_of_achievers: self.percent_earned,
                     achiever: { first_name: self.user.short_name }, image_path: self.image_path },
      user:        { username: self.user.username } }
  end

  def event_type
    :unlocked_achievement
  end

end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: badges
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer          indexed, indexed => [badge_class_name]
#  badge_class_name :string(255)      indexed => [user_id]
#
# Indexes
#
#  index_badges_on_user_id                       (user_id)
#  index_badges_on_user_id_and_badge_class_name  (user_id,badge_class_name) UNIQUE
#
