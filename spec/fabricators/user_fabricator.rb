# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  username                      :citext
#  name                          :string(255)
#  email                         :citext
#  location                      :string(255)
#  old_github_token              :string(255)
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
#  last_request_at               :datetime         default(2014-07-23 03:14:36 UTC)
#  achievements_checked_at       :datetime         default(1911-08-12 21:49:21 UTC)
#  claim_code                    :text
#  github_id                     :integer
#  country                       :string(255)
#  city                          :string(255)
#  state_name                    :string(255)
#  lat                           :float
#  lng                           :float
#  http_counter                  :integer
#  github_token                  :string(255)
#  twitter_checked_at            :datetime         default(1911-08-12 21:49:21 UTC)
#  title                         :string(255)
#  company                       :string(255)
#  blog                          :string(255)
#  github                        :citext
#  forrst                        :string(255)
#  dribbble                      :string(255)
#  specialties                   :text
#  notify_on_award               :boolean          default(TRUE)
#  receive_newsletter            :boolean          default(TRUE)
#  zerply                        :string(255)
#  linkedin                      :string(255)
#  linkedin_id                   :string(255)
#  linkedin_token                :string(255)
#  twitter_id                    :string(255)
#  twitter_token                 :string(255)
#  twitter_secret                :string(255)
#  linkedin_secret               :string(255)
#  last_email_sent               :datetime
#  linkedin_public_url           :string(255)
#  redemptions                   :text
#  endorsements_count            :integer          default(0)
#  team_document_id              :string(255)
#  speakerdeck                   :string(255)
#  slideshare                    :string(255)
#  last_refresh_at               :datetime         default(1970-01-01 00:00:00 UTC)
#  referral_token                :string(255)
#  referred_by                   :string(255)
#  about                         :text
#  joined_github_on              :date
#  avatar                        :string(255)
#  banner                        :string(255)
#  remind_to_invite_team_members :datetime
#  activated_on                  :datetime
#  tracking_code                 :string(255)
#  utm_campaign                  :string(255)
#  score_cache                   :float            default(0.0)
#  gender                        :string(255)
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
#  stat_name_1                   :string(255)
#  stat_number_1                 :string(255)
#  stat_name_2                   :string(255)
#  stat_number_2                 :string(255)
#  stat_name_3                   :string(255)
#  stat_number_3                 :string(255)
#  ip_lat                        :float
#  ip_lng                        :float
#  penalty                       :float            default(0.0)
#  receive_weekly_digest         :boolean          default(TRUE)
#  github_failures               :integer          default(0)
#  resume                        :string(255)
#  sourceforge                   :string(255)
#  google_code                   :string(255)
#  sales_rep                     :boolean          default(FALSE)
#  visits                        :string(255)      default("")
#  visit_frequency               :string(255)      default("rarely")
#  pitchbox_id                   :integer
#  join_badge_orgs               :boolean          default(FALSE)
#  use_social_for_pitchbox       :boolean          default(FALSE)
#  last_asm_email_at             :datetime
#  banned_at                     :datetime
#  last_ip                       :string(255)
#  last_ua                       :string(255)
#  team_id                       :integer
#

Fabricator(:user, from: 'User') do
  github { 'mdeiters' }
  twitter { 'mdeiters' }
  username { Faker::Internet.user_name.gsub(/\./, '_') }
  name { 'Matthew Deiters' }
  email { 'someone@example.com' }
  location { 'San Francisco' }
  github_token { Faker::Internet.ip_v4_address }
  state { User::ACTIVE }
end

Fabricator(:pending_user, from: 'User') do
  github { 'bguthrie' }
  username { Faker::Internet.user_name.gsub(/\./, '_') }
  name { 'Brian Guthrie' }
  email { 'someone@example.com' }
  location { 'Mountain View' }
  github_token { Faker::Internet.ip_v4_address }
  state { User::PENDING }
end
