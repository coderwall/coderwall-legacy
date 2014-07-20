class Follow < ActiveRecord::Base
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, polymorphic: true
  belongs_to :follower, polymorphic: true
  after_create :generate_event

  def block!
    self.update_attribute(:blocked, true)
  end

  def generate_event
    if followable.kind_of?(User) or followable.kind_of?(Team)
      GenerateEventJob.perform_async(self.event_type, Audience.user(self.followable.try(:id)), self.to_event_hash, 1.minute)
    end
  end

  def event_audience(event_type)
    if event_type == :followed_user
      Audience.user(self.followable.try(:id))
    elsif event_type == :followed_team
      Audience.team(self.followable.try(:id))
    end
  end

  def to_event_hash
    { follow: { followed: self.followable.try(:name), follower: self.follower.try(:name) },
      user:   { username: self.follower.try(:username) } }
  end

  def event_type
    "followed_#{followable.class.name.downcase}".to_sym
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: follows
#
#  id              :integer          not null, primary key
#  followable_id   :integer          not null, indexed => [followable_type], indexed => [followable_type, follower_id]
#  followable_type :string(255)      not null, indexed => [followable_id], indexed => [followable_id, follower_id]
#  follower_id     :integer          not null, indexed => [follower_type], indexed => [followable_id, followable_type]
#  follower_type   :string(255)      not null, indexed => [follower_id]
#  blocked         :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  fk_followables                            (followable_id,followable_type)
#  fk_follows                                (follower_id,follower_type)
#  follows_uniq_followable_id_type_follower  (followable_id,followable_type,follower_id) UNIQUE
#
