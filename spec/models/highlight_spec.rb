# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `highlights`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`created_at`**   | `datetime`         |
# **`description`**  | `text`             |
# **`featured`**     | `boolean`          | `default(FALSE)`
# **`id`**           | `integer`          | `not null, primary key`
# **`updated_at`**   | `datetime`         |
# **`user_id`**      | `integer`          |
#
# ### Indexes
#
# * `index_highlights_on_featured`:
#     * **`featured`**
# * `index_highlights_on_user_id`:
#     * **`user_id`**
#

require 'spec_helper'

RSpec.describe Highlight, :type => :model do


end
