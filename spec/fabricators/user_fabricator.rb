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

# == Schema Information
# Schema version: 20140713193201
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  username                      :string(255)      indexed
#  name                          :string(255)
#  email                         :string(255)
#  location                      :string(255)
#  old_github_token              :string(255)      indexed
#  state                         :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  twitter                       :string(255)
#  linkedin_legacy               :string(255)
#  stackoverflow                 :string(255)
#  admin                         :boolean          default(FALSE)
#  backup_email                  :string(255)
#  badges_count                  :integer          default(0)
#  bitbucket                     :string(255)
#  codeplex                      :string(255)
#  login_count                   :integer          default(0)
#  last_request_at               :datetime
#  achievements_checked_at       :datetime         default(1914-02-20 22:39:10 UTC)
#  claim_code                    :text
#  github_id                     :integer
#  country                       :string(255)
#  city                          :string(255)
#  state_name                    :string(255)
#  lat                           :float
#  lng                           :float
#  http_counter                  :integer
#  github_token                  :string(255)
#  twitter_checked_at            :datetime         default(1914-02-20 22:39:10 UTC)
#  title                         :string(255)
#  company                       :string(255)
#  blog                          :string(255)
#  github                        :string(255)
#  forrst                        :string(255)
#  dribbble                      :string(255)
#  specialties                   :text
#  notify_on_award               :boolean          default(TRUE)
#  receive_newsletter            :boolean          default(TRUE)
#  zerply                        :string(255)
#  thumbnail_url                 :text
#  linkedin                      :string(255)
#  linkedin_id                   :string(255)      indexed
#  linkedin_token                :string(255)
#  twitter_id                    :string(255)      indexed
#  twitter_token                 :string(255)
#  twitter_secret                :string(255)
#  linkedin_secret               :string(255)
#  last_email_sent               :datetime
#  linkedin_public_url           :string(255)
#  redemptions                   :text
#  endorsements_count            :integer          default(0)
#  team_document_id              :string(255)      indexed
#  speakerdeck                   :string(255)
#  slideshare                    :string(255)
#  last_refresh_at               :datetime         default(1970-01-01 00:00:00 UTC)
#  referral_token                :string(255)
#  referred_by                   :string(255)
#  about                         :text
#  joined_github_on              :date
#  joined_twitter_on             :date
#  avatar                        :string(255)
#  banner                        :string(255)
#  remind_to_invite_team_members :datetime
#  activated_on                  :datetime
#  tracking_code                 :string(255)
#  utm_campaign                  :string(255)
#  score_cache                   :float            default(0.0)
#  notify_on_follow              :boolean          default(TRUE)
#  api_key                       :string(255)
#  remind_to_create_team         :datetime
#  remind_to_create_protip       :datetime
#  remind_to_create_skills       :datetime
#  remind_to_link_accounts       :datetime
#  favorite_websites             :string(255)
#  team_responsibilities         :text
#  team_avatar                   :string(255)
#  team_banner                   :string(255)
#  ip_lat                        :float
#  ip_lng                        :float
#  penalty                       :float            default(0.0)
#  receive_weekly_digest         :boolean          default(TRUE)
#  github_failures               :integer          default(0)
#  resume                        :string(255)
#  sourceforge                   :string(255)
#  google_code                   :string(255)
#  visits                        :string(255)      default("")
#  visit_frequency               :string(255)      default("rarely")
#  join_badge_orgs               :boolean          default(FALSE)
#  last_asm_email_at             :datetime
#  banned_at                     :datetime
#  last_ip                       :string(255)
#  last_ua                       :string(255)
#
# Indexes
#
#  index_users_on_github_token      (old_github_token) UNIQUE
#  index_users_on_linkedin_id       (linkedin_id) UNIQUE
#  index_users_on_team_document_id  (team_document_id)
#  index_users_on_twitter_id        (twitter_id) UNIQUE
#  index_users_on_username          (username) UNIQUE
#
