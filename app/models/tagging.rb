# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `taggings`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`context`**        | `string(255)`      |
# **`created_at`**     | `datetime`         |
# **`id`**             | `integer`          | `not null, primary key`
# **`tag_id`**         | `integer`          |
# **`taggable_id`**    | `integer`          |
# **`taggable_type`**  | `string(255)`      |
# **`tagger_id`**      | `integer`          |
# **`tagger_type`**    | `string(255)`      |
#
# ### Indexes
#
# * `index_taggings_on_tag_id`:
#     * **`tag_id`**
# * `index_taggings_on_taggable_id_and_taggable_type_and_context`:
#     * **`taggable_id`**
#     * **`taggable_type`**
#     * **`context`**
#

class Tagging < ActiveRecord::Base
  belongs_to :tag
end
