# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `skills`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`attended_events`**     | `text`             |
# **`created_at`**          | `datetime`         |
# **`deleted`**             | `boolean`          | `default(FALSE), not null`
# **`deleted_at`**          | `datetime`         |
# **`endorsements_count`**  | `integer`          | `default(0)`
# **`id`**                  | `integer`          | `not null, primary key`
# **`name`**                | `string(255)`      | `not null`
# **`repos`**               | `text`             |
# **`speaking_events`**     | `text`             |
# **`tokenized`**           | `string(255)`      |
# **`updated_at`**          | `datetime`         |
# **`user_id`**             | `integer`          |
# **`weight`**              | `integer`          | `default(0)`
#
# ### Indexes
#
# * `index_skills_on_deleted_and_user_id`:
#     * **`deleted`**
#     * **`user_id`**
# * `index_skills_on_user_id`:
#     * **`user_id`**
#

Fabricator(:skill) do
  name { 'Ruby' }
end
