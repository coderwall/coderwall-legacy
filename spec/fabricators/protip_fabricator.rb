# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `protips`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`body`**                 | `text`             |
# **`boost_factor`**         | `float`            | `default(1.0)`
# **`created_at`**           | `datetime`         |
# **`created_by`**           | `string(255)`      | `default("self")`
# **`featured`**             | `boolean`          | `default(FALSE)`
# **`featured_at`**          | `datetime`         |
# **`id`**                   | `integer`          | `not null, primary key`
# **`inappropriate`**        | `integer`          | `default(0)`
# **`kind`**                 | `string(255)`      |
# **`public_id`**            | `string(255)`      |
# **`score`**                | `float`            |
# **`title`**                | `string(255)`      |
# **`updated_at`**           | `datetime`         |
# **`upvotes_value_cache`**  | `integer`          |
# **`user_id`**              | `integer`          |
#
# ### Indexes
#
# * `index_protips_on_public_id`:
#     * **`public_id`**
# * `index_protips_on_user_id`:
#     * **`user_id`**
#

Fabricator(:protip) do
  topics ["Javascript", "CoffeeScript"]
  title { Faker::Company.catch_phrase }
  body { Faker::Lorem.sentences(8).join(' ') }
  user { Fabricate.build(:user) }
end

Fabricator(:link_protip, from: :protip) do
  body "http://www.google.com"
end
