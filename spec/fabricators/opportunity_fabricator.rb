# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `opportunities`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`apply`**             | `boolean`          | `default(FALSE)`
# **`cached_tags`**       | `string(255)`      |
# **`created_at`**        | `datetime`         |
# **`deleted`**           | `boolean`          | `default(FALSE)`
# **`deleted_at`**        | `datetime`         |
# **`description`**       | `text`             |
# **`designation`**       | `string(255)`      |
# **`expires_at`**        | `datetime`         | `default(1970-01-01 00:00:00 UTC)`
# **`id`**                | `integer`          | `not null, primary key`
# **`link`**              | `string(255)`      |
# **`location`**          | `string(255)`      |
# **`location_city`**     | `string(255)`      |
# **`name`**              | `string(255)`      |
# **`opportunity_type`**  | `string(255)`      | `default("full-time")`
# **`options`**           | `float`            |
# **`public_id`**         | `string(255)`      |
# **`salary`**            | `integer`          |
# **`team_document_id`**  | `string(255)`      |
# **`updated_at`**        | `datetime`         |
#

Fabricator(:opportunity) do
  salary 100000
  name "Senior Rails Web Developer"
  description "Architect and implement the Ruby and Javascript underpinnings of our various user-facing and internal web apps like api.heroku.com."
  tags ["rails", "sinatra", "JQuery", "Clean, beautiful code"]
  location "San Francisco, CA"
  cached_tags "java, python"
  team_document_id { Fabricate(:team, paid_job_posts: 1).id }
end

Fabricator(:job, from: :opportunity, class_name: :opportunity) do

end
