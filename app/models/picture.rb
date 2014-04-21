# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `pictures`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`created_at`**  | `datetime`         |
# **`file`**        | `string(255)`      |
# **`id`**          | `integer`          | `not null, primary key`
# **`updated_at`**  | `datetime`         |
# **`user_id`**     | `integer`          |
#

class Picture < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  mount_uploader :file, PictureUploader

  belongs_to :user
end
