# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `seized_opportunities`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`created_at`**        | `datetime`         |
# **`id`**                | `integer`          | `not null, primary key`
# **`opportunity_id`**    | `integer`          |
# **`opportunity_type`**  | `string(255)`      |
# **`team_document_id`**  | `string(255)`      |
# **`updated_at`**        | `datetime`         |
# **`user_id`**           | `integer`          |
#

class SeizedOpportunity < ActiveRecord::Base
end
