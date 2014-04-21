# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `badges`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`badge_class_name`**  | `string(255)`      |
# **`created_at`**        | `datetime`         |
# **`id`**                | `integer`          | `not null, primary key`
# **`updated_at`**        | `datetime`         |
# **`user_id`**           | `integer`          |
#
# ### Indexes
#
# * `index_badges_on_user_id`:
#     * **`user_id`**
# * `index_badges_on_user_id_and_badge_class_name` (_unique_):
#     * **`user_id`**
#     * **`badge_class_name`**
#

Fabricator(:badge) do
  badge_class_name { sequence(:badge_name) { |i| "Octopussy" } }
end
