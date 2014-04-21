# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `invitations`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`created_at`**        | `datetime`         |
# **`email`**             | `string(255)`      |
# **`id`**                | `integer`          | `not null, primary key`
# **`inviter_id`**        | `integer`          |
# **`state`**             | `string(255)`      |
# **`team_document_id`**  | `string(255)`      |
# **`token`**             | `string(255)`      |
# **`updated_at`**        | `datetime`         |
#

class Invitation < ActiveRecord::Base
end
