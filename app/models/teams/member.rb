class Teams::Member < ActiveRecord::Base
  belongs_to :team, class_name: 'Team',
             foreign_key: 'team_id',
             counter_cache: :team_size,
             touch: true
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :team_id

  scope :active, -> { where(state: 'active') }
  scope :pending, -> { where(state: 'pending') }
  scope :sorted, -> { active.joins(:user).order('users.score_cache DESC') }
  scope :top, ->(limit= 1) { sorted.limit(limit) }
end

# == Schema Information
#
# Table name: teams_members
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :string(255)      default("pending")
#
