# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `endorsements`
#
# ### Columns
#
# Name                     | Type               | Attributes
# ------------------------ | ------------------ | ---------------------------
# **`created_at`**         | `datetime`         |
# **`endorsed_user_id`**   | `integer`          |
# **`endorsing_user_id`**  | `integer`          |
# **`id`**                 | `integer`          | `not null, primary key`
# **`skill_id`**           | `integer`          |
# **`specialty`**          | `string(255)`      |
# **`updated_at`**         | `datetime`         |
#
# ### Indexes
#
# * `index_endorsements_on_endorsed_user_id`:
#     * **`endorsed_user_id`**
# * `index_endorsements_on_endorsing_user_id`:
#     * **`endorsing_user_id`**
# * `only_unique_endorsements` (_unique_):
#     * **`endorsed_user_id`**
#     * **`endorsing_user_id`**
#     * **`specialty`**
#

Fabricator(:endorsement) do
  endorsed(fabricator: :user)
  endorser(fabricator: :user)
  skill(fabricator: :skill)
end
