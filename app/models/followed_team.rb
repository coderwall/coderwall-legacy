# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `followed_teams`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`created_at`**        | `datetime`         | `default(2014-02-20 22:39:11 UTC)`
# **`id`**                | `integer`          | `not null, primary key`
# **`team_document_id`**  | `string(255)`      |
# **`user_id`**           | `integer`          |
#
# ### Indexes
#
# * `index_followed_teams_on_team_document_id`:
#     * **`team_document_id`**
# * `index_followed_teams_on_user_id`:
#     * **`user_id`**
#

class FollowedTeam < ActiveRecord::Base
end
