# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `countries`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`code`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`id`**          | `integer`          | `not null, primary key`
# **`name`**        | `string(255)`      |
# **`updated_at`**  | `datetime`         |
#

class Country < ActiveRecord::Base
end
