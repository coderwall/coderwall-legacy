# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `likes`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`created_at`**     | `datetime`         |
# **`id`**             | `integer`          | `not null, primary key`
# **`ip_address`**     | `string(255)`      |
# **`likable_id`**     | `integer`          |
# **`likable_type`**   | `string(255)`      |
# **`tracking_code`**  | `string(255)`      |
# **`updated_at`**     | `datetime`         |
# **`user_id`**        | `integer`          |
# **`value`**          | `integer`          |
#
# ### Indexes
#
# * `index_likes_on_user_id` (_unique_):
#     * **`likable_id`**
#     * **`likable_type`**
#     * **`user_id`**
#

class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :likable, polymorphic: true

  validates :likable, presence: true
  validates :value, presence: true, numericality: { min: 1 }
  after_save :liked_callback

  scope :protips, where(likable_type: 'Protip')
  scope :protips_score, ->(protip_ids) { protips.where(likable_id: protip_ids).group(:likable_id).select('SUM(likes.value) as like_score') }

  def liked_callback
    likable.try(:liked, value)
  end
end
