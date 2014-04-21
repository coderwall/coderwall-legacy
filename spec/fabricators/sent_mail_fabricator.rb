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

Fabricator(:sent_mail) do
end
