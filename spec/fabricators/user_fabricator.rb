# ## Schema Information
# Schema version: 20131205021701
#
# Table name: `users`
#
# ### Columns
#
# Name                                 | Type               | Attributes
# ------------------------------------ | ------------------ | ---------------------------
# **`about`**                          | `text`             |
# **`achievements_checked_at`**        | `datetime`         | `default(1914-02-20 22:39:10 UTC)`
# **`activated_on`**                   | `datetime`         |
# **`admin`**                          | `boolean`          | `default(FALSE)`
# **`api_key`**                        | `string(255)`      |
# **`avatar`**                         | `string(255)`      |
# **`backup_email`**                   | `string(255)`      |
# **`badges_count`**                   | `integer`          | `default(0)`
# **`banner`**                         | `string(255)`      |
# **`beta_access`**                    | `boolean`          | `default(FALSE)`
# **`bitbucket`**                      | `string(255)`      |
# **`blog`**                           | `string(255)`      |
# **`city`**                           | `string(255)`      |
# **`claim_code`**                     | `text`             |
# **`codeplex`**                       | `string(255)`      |
# **`company`**                        | `string(255)`      |
# **`country`**                        | `string(255)`      |
# **`created_at`**                     | `datetime`         |
# **`dribbble`**                       | `string(255)`      |
# **`email`**                          | `string(255)`      |
# **`endorsements_count`**             | `integer`          | `default(0)`
# **`favorite_websites`**              | `string(255)`      |
# **`forrst`**                         | `string(255)`      |
# **`github`**                         | `string(255)`      |
# **`github_failures`**                | `integer`          | `default(0)`
# **`github_id`**                      | `integer`          |
# **`github_token`**                   | `string(255)`      |
# **`google_code`**                    | `string(255)`      |
# **`http_counter`**                   | `integer`          |
# **`id`**                             | `integer`          | `not null, primary key`
# **`ip_lat`**                         | `float`            |
# **`ip_lng`**                         | `float`            |
# **`join_badge_orgs`**                | `boolean`          | `default(FALSE)`
# **`joined_github_on`**               | `date`             |
# **`joined_twitter_on`**              | `date`             |
# **`last_asm_email_at`**              | `datetime`         |
# **`last_email_sent`**                | `datetime`         |
# **`last_refresh_at`**                | `datetime`         | `default(1970-01-01 00:00:00 UTC)`
# **`last_request_at`**                | `datetime`         |
# **`lat`**                            | `float`            |
# **`linkedin`**                       | `string(255)`      |
# **`linkedin_id`**                    | `string(255)`      |
# **`linkedin_legacy`**                | `string(255)`      |
# **`linkedin_public_url`**            | `string(255)`      |
# **`linkedin_secret`**                | `string(255)`      |
# **`linkedin_token`**                 | `string(255)`      |
# **`lng`**                            | `float`            |
# **`location`**                       | `string(255)`      |
# **`login_count`**                    | `integer`          | `default(0)`
# **`name`**                           | `string(255)`      |
# **`notify_on_award`**                | `boolean`          | `default(TRUE)`
# **`notify_on_follow`**               | `boolean`          | `default(TRUE)`
# **`old_github_token`**               | `string(255)`      |
# **`penalty`**                        | `float`            | `default(0.0)`
# **`receive_newsletter`**             | `boolean`          | `default(TRUE)`
# **`receive_weekly_digest`**          | `boolean`          | `default(TRUE)`
# **`redemptions`**                    | `text`             |
# **`referral_token`**                 | `string(255)`      |
# **`referred_by`**                    | `string(255)`      |
# **`remind_to_create_protip`**        | `datetime`         |
# **`remind_to_create_skills`**        | `datetime`         |
# **`remind_to_create_team`**          | `datetime`         |
# **`remind_to_invite_team_members`**  | `datetime`         |
# **`remind_to_link_accounts`**        | `datetime`         |
# **`resume`**                         | `string(255)`      |
# **`score_cache`**                    | `float`            | `default(0.0)`
# **`slideshare`**                     | `string(255)`      |
# **`sourceforge`**                    | `string(255)`      |
# **`speakerdeck`**                    | `string(255)`      |
# **`specialties`**                    | `text`             |
# **`stackoverflow`**                  | `string(255)`      |
# **`state`**                          | `string(255)`      |
# **`state_name`**                     | `string(255)`      |
# **`team_avatar`**                    | `string(255)`      |
# **`team_banner`**                    | `string(255)`      |
# **`team_document_id`**               | `string(255)`      |
# **`team_responsibilities`**          | `text`             |
# **`thumbnail_url`**                  | `text`             |
# **`title`**                          | `string(255)`      |
# **`tracking_code`**                  | `string(255)`      |
# **`twitter`**                        | `string(255)`      |
# **`twitter_checked_at`**             | `datetime`         | `default(1914-02-20 22:39:10 UTC)`
# **`twitter_id`**                     | `string(255)`      |
# **`twitter_secret`**                 | `string(255)`      |
# **`twitter_token`**                  | `string(255)`      |
# **`updated_at`**                     | `datetime`         |
# **`username`**                       | `string(255)`      |
# **`utm_campaign`**                   | `string(255)`      |
# **`visit_frequency`**                | `string(255)`      | `default("rarely")`
# **`visits`**                         | `string(255)`      | `default("")`
# **`zerply`**                         | `string(255)`      |
#
# ### Indexes
#
# * `index_users_on_github_token` (_unique_):
#     * **`old_github_token`**
# * `index_users_on_linkedin_id` (_unique_):
#     * **`linkedin_id`**
# * `index_users_on_team_document_id`:
#     * **`team_document_id`**
# * `index_users_on_twitter_id` (_unique_):
#     * **`twitter_id`**
# * `index_users_on_username` (_unique_):
#     * **`username`**
#

Fabricator(:user) do
  github { 'mdeiters' }
  twitter { 'mdeiters' }
  username { Faker::Internet.user_name.gsub(/\./, "_") }
  name { 'Matthew Deiters' }
  email { 'someone@example.com' }
  location { 'San Francisco' }
  github_token { Faker::Internet.ip_v4_address }
  state { User::ACTIVE }
end

Fabricator(:pending_user, from: :user) do
  github { 'bguthrie' }
  username { Faker::Internet.user_name.gsub(/\./, "_") }
  name { 'Brian Guthrie' }
  email { 'someone@example.com' }
  location { 'Mountain View' }
  github_token { Faker::Internet.ip_v4_address }
  state { User::PENDING }
end
