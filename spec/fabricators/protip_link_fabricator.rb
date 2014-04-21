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

Fabricator(:protip_link) do
  identifier 1
  url "MyString"
end
