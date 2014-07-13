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

require 'spec_helper'

RSpec.describe Like, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"
end
