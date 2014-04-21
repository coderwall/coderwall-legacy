# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `network_experts`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`created_at`**   | `datetime`         |
# **`designation`**  | `string(255)`      |
# **`id`**           | `integer`          | `not null, primary key`
# **`network_id`**   | `integer`          |
# **`updated_at`**   | `datetime`         |
# **`user_id`**      | `integer`          |
#

class NetworkExpert < ActiveRecord::Base
  belongs_to :network
  belongs_to :user

  DESIGNATIONS = %(mayor resident_expert)

  validates :designation, presence: true, inclusion: { in: DESIGNATIONS }
end
