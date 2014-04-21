# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `sent_mails`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`mailable_id`**    | `integer`          |
# **`mailable_type`**  | `string(255)`      |
# **`sent_at`**        | `datetime`         |
# **`user_id`**        | `integer`          |
#

class SentMail < ActiveRecord::Base
  belongs_to :mailable, polymorphic: true
  belongs_to :user

  alias_attribute :receiver, :user
end
