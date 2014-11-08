# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141015182230) do

  add_extension "citext"

  create_table "alias_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "alias_id"
  end

  add_index "alias_tags", ["alias_id"], :name => "index_alias_tags_on_alias_id"
  add_index "alias_tags", ["tag_id"], :name => "index_alias_tags_on_tag_id"

  create_table "api_accesses", :force => true do |t|
    t.string   "api_key"
    t.text     "awards"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "available_coupons", :force => true do |t|
    t.string "codeschool_coupon"
    t.string "peepcode_coupon"
    t.string "recipes_coupon"
  end

  add_index "available_coupons", ["codeschool_coupon"], :name => "index_available_coupons_on_codeschool_coupon", :unique => true
  add_index "available_coupons", ["peepcode_coupon"], :name => "index_available_coupons_on_peepcode_coupon", :unique => true

  create_table "badges", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "badge_class_name"
  end

  add_index "badges", ["user_id", "badge_class_name"], :name => "index_badges_on_user_id_and_badge_class_name", :unique => true
  add_index "badges", ["user_id"], :name => "index_badges_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "title",             :limit => 50, :default => ""
    t.text     "comment",                         :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.integer  "likes_cache",                     :default => 0
    t.integer  "likes_value_cache",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes_count",                     :default => 0
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "endorsements", :force => true do |t|
    t.integer  "endorsed_user_id"
    t.integer  "endorsing_user_id"
    t.string   "specialty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "skill_id"
  end

  add_index "endorsements", ["endorsed_user_id", "endorsing_user_id", "specialty"], :name => "only_unique_endorsements", :unique => true
  add_index "endorsements", ["endorsed_user_id"], :name => "index_endorsements_on_endorsed_user_id"
  add_index "endorsements", ["endorsing_user_id"], :name => "index_endorsements_on_endorsing_user_id"

  create_table "facts", :force => true do |t|
    t.string   "identity"
    t.string   "owner"
    t.string   "name"
    t.string   "url"
    t.text     "tags"
    t.text     "metadata"
    t.datetime "relevant_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facts", ["identity"], :name => "index_facts_on_identity"
  add_index "facts", ["owner"], :name => "index_facts_on_owner"

  create_table "followed_teams", :force => true do |t|
    t.integer  "user_id"
    t.string   "team_document_id"
    t.datetime "created_at",       :default => '2014-02-20 22:39:11'
  end

  add_index "followed_teams", ["team_document_id"], :name => "index_followed_teams_on_team_document_id"
  add_index "followed_teams", ["user_id"], :name => "index_followed_teams_on_user_id"

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type", "follower_id"], :name => "follows_uniq_followable_id_type_follower", :unique => true
  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "github_assignments", :force => true do |t|
    t.string   "github_username"
    t.string   "repo_url"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "badge_class_name"
  end

  add_index "github_assignments", ["github_username", "badge_class_name"], :name => "index_assignments_on_username_and_badge_class_name", :unique => true
  add_index "github_assignments", ["github_username", "repo_url", "tag"], :name => "index_assignments_on_username_and_repo_url_and_badge_class_name", :unique => true
  add_index "github_assignments", ["repo_url"], :name => "index_assignments_on_repo_url"

  create_table "highlights", :force => true do |t|
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",    :default => false
  end

  add_index "highlights", ["featured"], :name => "index_highlights_on_featured"
  add_index "highlights", ["user_id"], :name => "index_highlights_on_user_id"

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.string   "team_document_id"
    t.string   "token"
    t.string   "state"
    t.integer  "inviter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", :force => true do |t|
    t.integer  "value"
    t.string   "tracking_code"
    t.integer  "user_id"
    t.integer  "likable_id"
    t.string   "likable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
  end

  add_index "likes", ["likable_id", "likable_type", "user_id"], :name => "index_likes_on_user_id", :unique => true

  create_table "network_experts", :force => true do |t|
    t.string   "designation"
    t.integer  "network_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "protips_count_cache", :default => 0
    t.boolean  "featured",            :default => false
  end

  create_table "opportunities", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "designation"
    t.string   "location"
    t.string   "cached_tags"
    t.string   "team_document_id"
    t.string   "link"
    t.integer  "salary"
    t.float    "options"
    t.boolean  "deleted",          :default => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at",       :default => '1970-01-01 00:00:00'
    t.string   "opportunity_type", :default => "full-time"
    t.string   "location_city"
    t.boolean  "apply",            :default => false
    t.string   "public_id"
    t.integer  "team_id"
  end

  create_table "pictures", :force => true do |t|
    t.integer  "user_id"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.integer  "amount"
    t.string   "interval",            :default => "month"
    t.string   "name"
    t.string   "currency",            :default => "usd"
    t.string   "public_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "analytics",           :default => false
    t.integer  "interval_in_seconds", :default => 2592000
  end

  create_table "protip_links", :force => true do |t|
    t.string   "identifier"
    t.string   "url"
    t.integer  "protip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
  end

  create_table "protips", :force => true do |t|
    t.string   "public_id"
    t.string   "kind"
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score"
    t.string   "created_by",          :default => "self"
    t.boolean  "featured",            :default => false
    t.datetime "featured_at"
    t.integer  "upvotes_value_cache", :default => 0,      :null => false
    t.float    "boost_factor",        :default => 1.0
    t.integer  "inappropriate",       :default => 0
    t.integer  "likes_count",         :default => 0
    t.string   "slug"
  end

  add_index "protips", ["public_id"], :name => "index_protips_on_public_id"
  add_index "protips", ["slug"], :name => "index_protips_on_slug"
  add_index "protips", ["user_id"], :name => "index_protips_on_user_id"

  create_table "purchased_bundles", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "codeschool_coupon"
    t.string   "peepcode_coupon"
    t.string   "credit_card_id"
    t.string   "stripe_purchase_id"
    t.string   "stripe_customer_id"
    t.text     "stripe_response"
    t.integer  "total_amount"
    t.integer  "coderwall_proceeds"
    t.integer  "codeschool_proceeds"
    t.integer  "charity_proceeds"
    t.integer  "peepcode_proceeds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipes_coupon"
  end

  create_table "reserved_teams", :force => true do |t|
    t.integer "user_id"
    t.text    "name"
    t.text    "company"
  end

  create_table "seized_opportunities", :force => true do |t|
    t.integer  "opportunity_id"
    t.string   "opportunity_type"
    t.integer  "user_id"
    t.string   "team_document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_mails", :force => true do |t|
    t.integer  "mailable_id"
    t.string   "mailable_type"
    t.integer  "user_id"
    t.datetime "sent_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "skills", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                                  :null => false
    t.integer  "endorsements_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tokenized"
    t.integer  "weight",             :default => 0
    t.text     "repos"
    t.text     "speaking_events"
    t.text     "attended_events"
    t.boolean  "deleted",            :default => false, :null => false
    t.datetime "deleted_at"
  end

  add_index "skills", ["deleted", "user_id"], :name => "index_skills_on_deleted_and_user_id"
  add_index "skills", ["user_id"], :name => "index_skills_on_user_id"

  create_table "spam_reports", :force => true do |t|
    t.integer  "spammable_id",   :null => false
    t.string   "spammable_type", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "teams", :force => true do |t|
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "website"
    t.text     "about"
    t.integer  "total",                    :default => 0
    t.integer  "size",                     :default => 0
    t.integer  "mean",                     :default => 0
    t.integer  "median",                   :default => 0
    t.integer  "score",                    :default => 0
    t.string   "twitter"
    t.string   "facebook"
    t.string   "slug"
    t.boolean  "premium",                  :default => false
    t.boolean  "analytics",                :default => false
    t.boolean  "valid_jobs",               :default => false
    t.boolean  "hide_from_featured",       :default => false
    t.string   "preview_code"
    t.string   "youtube_url"
    t.string   "github"
    t.string   "highlight_tags"
    t.text     "branding"
    t.text     "headline"
    t.text     "big_quote"
    t.string   "big_image"
    t.string   "featured_banner_image"
    t.text     "benefit_name_1"
    t.text     "benefit_description_1"
    t.text     "benefit_name_2"
    t.text     "benefit_description_2"
    t.text     "benefit_name_3"
    t.text     "benefit_description_3"
    t.text     "reason_name_1"
    t.text     "reason_description_1"
    t.text     "reason_name_2"
    t.text     "reason_description_2"
    t.text     "reason_name_3"
    t.text     "reason_description_3"
    t.text     "why_work_image"
    t.text     "organization_way"
    t.text     "organization_way_name"
    t.text     "organization_way_photo"
    t.string   "office_photos",            :default => [],                    :array => true
    t.string   "upcoming_events",          :default => [],                    :array => true
    t.string   "featured_links_title"
    t.text     "blog_feed"
    t.text     "our_challenge"
    t.text     "your_impact"
    t.string   "interview_steps",          :default => [],                    :array => true
    t.text     "hiring_tagline"
    t.text     "link_to_careers_page"
    t.string   "avatar"
    t.integer  "achievement_count",        :default => 0
    t.integer  "endorsement_count",        :default => 0
    t.string   "invited_emails",           :default => [],                    :array => true
    t.string   "pending_join_requests",    :default => [],                    :array => true
    t.datetime "upgraded_at"
    t.integer  "paid_job_posts",           :default => 0
    t.boolean  "monthly_subscription",     :default => false
    t.text     "stack_list",               :default => ""
    t.integer  "number_of_jobs_to_show",   :default => 2
    t.string   "location"
    t.integer  "country_id"
    t.string   "name"
    t.string   "github_organization_name"
    t.integer  "team_size"
  end

  create_table "teams_account_plans", :id => false, :force => true do |t|
    t.integer "plan_id"
    t.integer "account_id"
  end

  create_table "teams_accounts", :force => true do |t|
    t.integer  "team_id",               :null => false
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "stripe_card_token",     :null => false
    t.string   "stripe_customer_token", :null => false
    t.integer  "admin_id",              :null => false
    t.datetime "trial_end"
  end

  create_table "teams_links", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "team_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams_locations", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "address"
    t.string   "city"
    t.string   "state_code"
    t.string   "country"
    t.integer  "team_id",     :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "teams_members", :force => true do |t|
    t.integer  "team_id",                      :null => false
    t.integer  "user_id",                      :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "team_size",     :default => 0
    t.integer  "badges_count"
    t.string   "email"
    t.integer  "inviter_id"
    t.string   "name"
    t.string   "thumbnail_url"
    t.string   "username"
  end

  create_table "tokens", :force => true do |t|
    t.string   "token"
    t.string   "secret"
    t.string   "kind"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["kind", "user_id"], :name => "index_tokens_on_kind_and_user_id", :unique => true

  create_table "user_events", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "data"
    t.datetime "created_at", :default => '2014-02-20 22:39:11'
  end

  create_table "users", :force => true do |t|
    t.citext   "username"
    t.string   "name"
    t.citext   "email"
    t.string   "location"
    t.string   "old_github_token"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter"
    t.string   "linkedin_legacy"
    t.string   "stackoverflow"
    t.boolean  "admin",                         :default => false
    t.string   "backup_email"
    t.integer  "badges_count",                  :default => 0
    t.string   "bitbucket"
    t.string   "codeplex"
    t.integer  "login_count",                   :default => 0
    t.datetime "last_request_at",               :default => '2014-07-17 13:10:04'
    t.datetime "achievements_checked_at",       :default => '1914-02-20 22:39:10'
    t.text     "claim_code"
    t.integer  "github_id"
    t.string   "country"
    t.string   "city"
    t.string   "state_name"
    t.float    "lat"
    t.float    "lng"
    t.integer  "http_counter"
    t.string   "github_token"
    t.datetime "twitter_checked_at",            :default => '1914-02-20 22:39:10'
    t.string   "title"
    t.string   "company"
    t.string   "blog"
    t.citext   "github"
    t.string   "forrst"
    t.string   "dribbble"
    t.text     "specialties"
    t.boolean  "notify_on_award",               :default => true
    t.boolean  "receive_newsletter",            :default => true
    t.string   "zerply"
    t.string   "linkedin"
    t.string   "linkedin_id"
    t.string   "linkedin_token"
    t.string   "twitter_id"
    t.string   "twitter_token"
    t.string   "twitter_secret"
    t.string   "linkedin_secret"
    t.datetime "last_email_sent"
    t.string   "linkedin_public_url"
    t.text     "redemptions"
    t.integer  "endorsements_count",            :default => 0
    t.string   "team_document_id"
    t.string   "speakerdeck"
    t.string   "slideshare"
    t.datetime "last_refresh_at",               :default => '1970-01-01 00:00:00'
    t.string   "referral_token"
    t.string   "referred_by"
    t.text     "about"
    t.date     "joined_github_on"
    t.string   "avatar"
    t.string   "banner"
    t.datetime "remind_to_invite_team_members"
    t.datetime "activated_on"
    t.string   "tracking_code"
    t.string   "utm_campaign"
    t.float    "score_cache",                   :default => 0.0
    t.boolean  "notify_on_follow",              :default => true
    t.string   "api_key"
    t.datetime "remind_to_create_team"
    t.datetime "remind_to_create_protip"
    t.datetime "remind_to_create_skills"
    t.datetime "remind_to_link_accounts"
    t.string   "favorite_websites"
    t.text     "team_responsibilities"
    t.string   "team_avatar"
    t.string   "team_banner"
    t.float    "ip_lat"
    t.float    "ip_lng"
    t.float    "penalty",                       :default => 0.0
    t.boolean  "receive_weekly_digest",         :default => true
    t.integer  "github_failures",               :default => 0
    t.string   "resume"
    t.string   "sourceforge"
    t.string   "google_code"
    t.string   "visits",                        :default => ""
    t.string   "visit_frequency",               :default => "rarely"
    t.boolean  "join_badge_orgs",               :default => false
    t.datetime "last_asm_email_at"
    t.datetime "banned_at"
    t.string   "last_ip"
    t.string   "last_ua"
  end

  add_index "users", ["linkedin_id"], :name => "index_users_on_linkedin_id", :unique => true
  add_index "users", ["old_github_token"], :name => "index_users_on_github_token", :unique => true
  add_index "users", ["team_document_id"], :name => "index_users_on_team_document_id"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "users_github_organizations", :force => true do |t|
    t.string   "login"
    t.string   "company"
    t.string   "blog"
    t.string   "location"
    t.string   "url"
    t.integer  "github_id"
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users_github_organizations_followers", :id => false, :force => true do |t|
    t.integer  "organization_id", :null => false
    t.integer  "profile_id",      :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "users_github_profiles", :force => true do |t|
    t.citext   "login",                                :null => false
    t.string   "name"
    t.string   "company"
    t.string   "location"
    t.integer  "github_id"
    t.integer  "user_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "hireable",          :default => false
    t.integer  "followers_count",   :default => 0
    t.integer  "following_count",   :default => 0
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "spider_updated_at"
  end

  create_table "users_github_profiles_followers", :id => false, :force => true do |t|
    t.integer  "follower_id", :null => false
    t.integer  "profile_id",  :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users_github_repositories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "full_name"
    t.string   "homepage"
    t.boolean  "fork",                        :default => false
    t.integer  "forks_count",                 :default => 0
    t.datetime "forks_count_updated_at",      :default => '2014-07-18 23:03:00'
    t.integer  "stargazers_count",            :default => 0
    t.datetime "stargazers_count_updated_at", :default => '2014-07-18 23:03:00'
    t.string   "language"
    t.integer  "followers_count",             :default => 0,                     :null => false
    t.integer  "github_id",                                                      :null => false
    t.integer  "owner_id"
    t.integer  "organization_id"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  create_table "users_github_repositories_contributors", :id => false, :force => true do |t|
    t.integer  "repository_id", :null => false
    t.integer  "profile_id",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users_github_repositories_followers", :id => false, :force => true do |t|
    t.integer  "repository_id", :null => false
    t.integer  "profile_id",    :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
