# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `user_events`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`created_at`**  | `datetime`         | `default(2014-02-20 22:39:11 UTC)`
# **`data`**        | `text`             |
# **`id`**          | `integer`          | `not null, primary key`
# **`name`**        | `string(255)`      |
# **`user_id`**     | `integer`          |
#

class UserEvent < ActiveRecord::Base
  belongs_to :user
  serialize :data, Hash
end
