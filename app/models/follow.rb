class Follow < ActiveRecord::Base
  include ResqueSupport::Basic

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, polymorphic: true
  belongs_to :follower, polymorphic: true
  after_create :generate_event

  def block!
    update_attribute(:blocked, true)
  end

  def generate_event
    if followable.kind_of?(User) || followable.kind_of?(Team)
      enqueue(GenerateEvent, event_type, Audience.user(followable.try(:id)), to_event_hash, 1.minute)
    end
  end

  def event_audience(event_type)
    if event_type == :followed_user
      Audience.user(followable.try(:id))
    elsif event_type == :followed_team
      Audience.team(followable.try(:id))
    end
  end

  def to_event_hash
    { follow: { followed: followable.try(:name), follower: follower.try(:name) },
      user:   { username: follower.try(:username) } }
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
