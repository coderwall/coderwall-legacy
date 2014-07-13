# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `plans`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`amount`**      | `integer`          |
# **`analytics`**   | `boolean`          | `default(FALSE)`
# **`created_at`**  | `datetime`         |
# **`currency`**    | `string(255)`      |
# **`id`**          | `integer`          | `not null, primary key`
# **`interval`**    | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`public_id`**   | `string(255)`      |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

RSpec.describe Plan, :type => :model do
  skip "add some examples to (or delete) #{__FILE__}"
end
