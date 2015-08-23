# == Schema Information
#
# Table name: teams_members
#
#  id          :integer          not null, primary key
#  team_id     :integer          not null
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state       :string(255)      default("pending")
#  score_cache :float
#  team_banner :string(255)
#  team_avatar :string(255)
#  role        :string(255)      default("member")
#

# TODO: Move team_banner to uhhh... the Team. Maybe that would make sense.

class Teams::Member < ActiveRecord::Base
  belongs_to :team, class_name: 'Team',
    foreign_key: 'team_id',
    counter_cache: :team_size,
    touch: true
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :team_id
  validates :team_id, :user_id, :presence => true

  mount_uploader :team_avatar, AvatarUploader

  mount_uploader :team_banner, BannerUploader
  # process_in_background :team_banner, ResizeTiltShiftBannerJob


  scope :active, -> { where(state: 'active') }
  scope :pending, -> { where(state: 'pending') }
  scope :sorted, -> { active.joins(:user).order('users.score_cache DESC') }
  scope :top, ->(limit= 1) { sorted.limit(limit) }
  scope :members, -> { where(role: 'member') }
  scope :admins, -> { where(role: 'admin') }

  def score
    badges.all.sum(&:weight)
  end

  def display_name
    name || username
  end

  def admin?
    role == 'admin'
  end

  %i(
    banner
    city
    username
    avatar
    name
    about
    team_responsibilities
    speciality_tags
    state_name
    country
    referral_token
  ).each do |user_method|
    delegate user_method, to: :user
  end

  [:badges, :endorsements].each do |m|
    define_method(m) { user.try(m) }
  end
end
