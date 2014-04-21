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

class ApiAccess < ActiveRecord::Base
  serialize :awards, Array

  class << self
    def for(api_key)
      where(api_key: api_key).first
    end
  end

  def can_award?(badge_name)
    awards.include? badge_name
  end
end
