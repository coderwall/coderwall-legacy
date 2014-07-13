# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `api_accesses`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`api_key`**     | `string(255)`      |
# **`awards`**      | `text`             |
# **`created_at`**  | `datetime`         |
# **`id`**          | `integer`          | `not null, primary key`
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

RSpec.describe ApiAccess, :type => :model do

end
