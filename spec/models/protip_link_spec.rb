# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `protip_links`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`created_at`**  | `datetime`         |
# **`id`**          | `integer`          | `not null, primary key`
# **`identifier`**  | `string(255)`      |
# **`kind`**        | `string(255)`      |
# **`protip_id`**   | `integer`          |
# **`updated_at`**  | `datetime`         |
# **`url`**         | `string(255)`      |
#

require 'spec_helper'

RSpec.describe ProtipLink, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"
end
