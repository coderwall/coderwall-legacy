class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true

  validates :likable, presence: true
  validates :value, presence: true, numericality: { min: 1 }
  after_save :liked_callback

  scope :protips, where(likable_type: 'Protip')
  scope :protips_score, ->(protip_ids) { protips.where(likable_id: protip_ids).group(:likable_id).select('SUM(likes.value) as like_score') }

  def liked_callback
    likable.try(:liked, value)
  end
end

# == Schema Information
# Schema version: 20140728214411
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  value         :integer
#  tracking_code :string(255)
#  user_id       :integer
#  likable_id    :integer
#  likable_type  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  ip_address    :string(255)
#
