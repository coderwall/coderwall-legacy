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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150225094555) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

  create_table "api_accesses", force: :cascade do |t|
    t.string   "api_key",    limit: 255
    t.text     "awards"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "available_coupons", force: :cascade do |t|
    t.string "codeschool_coupon", limit: 255
    t.string "peepcode_coupon",   limit: 255
    t.string "recipes_coupon",    limit: 255
  end

  add_index "available_coupons", ["codeschool_coupon"], name: "index_available_coupons_on_codeschool_coupon", unique: true, using: :btree
  add_index "available_coupons", ["peepcode_coupon"], name: "index_available_coupons_on_peepcode_coupon", unique: true, using: :btree

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "badge_class_name", limit: 255
  end

  add_index "badges", ["user_id", "badge_class_name"], name: "index_badges_on_user_id_and_badge_class_name", unique: true, using: :btree
  add_index "badges", ["user_id"], name: "index_badges_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",             limit: 50,  default: ""
    t.text     "comment",                       default: ""
    t.integer  "commentable_id"
    t.string   "commentable_type",  limit: 255
    t.integer  "user_id"
    t.integer  "likes_cache",                   default: 0
    t.integer  "likes_value_cache",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes_count",                   default: 0
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "endorsements", force: :cascade do |t|
    t.integer  "endorsed_user_id"
    t.integer  "endorsing_user_id"
    t.string   "specialty",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "skill_id"
  end

  add_index "endorsements", ["endorsed_user_id", "endorsing_user_id", "specialty"], name: "only_unique_endorsements", unique: true, using: :btree
  add_index "endorsements", ["endorsed_user_id"], name: "index_endorsements_on_endorsed_user_id", using: :btree
  add_index "endorsements", ["endorsing_user_id"], name: "index_endorsements_on_endorsing_user_id", using: :btree

  create_table "facts", force: :cascade do |t|
    t.string   "identity",    limit: 255
    t.string   "owner",       limit: 255
    t.string   "name",        limit: 255
    t.string   "url",         limit: 255
    t.text     "tags"
    t.text     "metadata"
    t.datetime "relevant_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facts", ["identity"], name: "index_facts_on_identity", using: :btree
  add_index "facts", ["owner"], name: "index_facts_on_owner", using: :btree

  create_table "followed_teams", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "team_document_id", limit: 255
    t.datetime "created_at",                   default: '2012-03-12 21:01:09'
    t.integer  "team_id"
  end

  add_index "followed_teams", ["team_document_id"], name: "index_followed_teams_on_team_document_id", using: :btree
  add_index "followed_teams", ["user_id"], name: "index_followed_teams_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id",                               null: false
    t.string   "followable_type", limit: 255,                 null: false
    t.integer  "follower_id",                                 null: false
    t.string   "follower_type",   limit: 255,                 null: false
    t.boolean  "blocked",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type", "follower_id"], name: "follows_uniq_followable_id_type_follower", unique: true, using: :btree
  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "github_assignments", force: :cascade do |t|
    t.string   "github_username",  limit: 255
    t.string   "repo_url",         limit: 255
    t.string   "tag",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "badge_class_name", limit: 255
  end

  add_index "github_assignments", ["github_username", "badge_class_name"], name: "index_assignments_on_username_and_badge_class_name", unique: true, using: :btree
  add_index "github_assignments", ["github_username", "repo_url", "tag"], name: "index_assignments_on_username_and_repo_url_and_badge_class_name", unique: true, using: :btree
  add_index "github_assignments", ["repo_url"], name: "index_assignments_on_repo_url", using: :btree

  create_table "highlights", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",    default: false
  end

  add_index "highlights", ["featured"], name: "index_highlights_on_featured", using: :btree
  add_index "highlights", ["user_id"], name: "index_highlights_on_user_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.string   "team_document_id", limit: 255
    t.string   "token",            limit: 255
    t.string   "state",            limit: 255
    t.integer  "inviter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "value"
    t.string   "tracking_code", limit: 255
    t.integer  "user_id"
    t.integer  "likable_id"
    t.string   "likable_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",    limit: 255
  end

  add_index "likes", ["likable_id", "likable_type", "user_id"], name: "index_likes_on_user_id", unique: true, using: :btree

  create_table "network_experts", force: :cascade do |t|
    t.string   "designation", limit: 255
    t.integer  "network_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "slug",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "protips_count_cache",             default: 0
    t.boolean  "featured",                        default: false
  end

  create_table "opportunities", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description"
    t.string   "designation",      limit: 255
    t.string   "location",         limit: 255
    t.string   "cached_tags",      limit: 255
    t.string   "team_document_id", limit: 255
    t.string   "link",             limit: 255
    t.integer  "salary"
    t.float    "options"
    t.boolean  "deleted",                      default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at",                   default: '1970-01-01 00:00:00'
    t.string   "opportunity_type", limit: 255, default: "full-time"
    t.string   "location_city",    limit: 255
    t.boolean  "apply",                        default: false
    t.string   "public_id",        limit: 255
    t.integer  "team_id"
    t.boolean  "remote"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "file",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "amount"
    t.string   "interval",            limit: 255, default: "month"
    t.string   "name",                limit: 255
    t.string   "currency",            limit: 255, default: "usd"
    t.string   "public_id",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "analytics",                       default: false
    t.integer  "interval_in_seconds",             default: 2592000
  end

  create_table "protip_links", force: :cascade do |t|
    t.string   "identifier", limit: 255
    t.string   "url",        limit: 255
    t.integer  "protip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",       limit: 255
  end

  create_table "protips", force: :cascade do |t|
    t.string   "public_id",           limit: 255
    t.string   "kind",                limit: 255
    t.string   "title",               limit: 255
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score"
    t.string   "created_by",          limit: 255, default: "self"
    t.boolean  "featured",                        default: false
    t.datetime "featured_at"
    t.integer  "upvotes_value_cache",             default: 0,      null: false
    t.float    "boost_factor",                    default: 1.0
    t.integer  "inappropriate",                   default: 0
    t.integer  "likes_count",                     default: 0
    t.string   "slug",                limit: 255,                  null: false
  end

  add_index "protips", ["public_id"], name: "index_protips_on_public_id", using: :btree
  add_index "protips", ["slug"], name: "index_protips_on_slug", using: :btree
  add_index "protips", ["user_id"], name: "index_protips_on_user_id", using: :btree

  create_table "purchased_bundles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",               limit: 255
    t.string   "codeschool_coupon",   limit: 255
    t.string   "peepcode_coupon",     limit: 255
    t.string   "credit_card_id",      limit: 255
    t.string   "stripe_purchase_id",  limit: 255
    t.string   "stripe_customer_id",  limit: 255
    t.text     "stripe_response"
    t.integer  "total_amount"
    t.integer  "coderwall_proceeds"
    t.integer  "codeschool_proceeds"
    t.integer  "charity_proceeds"
    t.integer  "peepcode_proceeds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipes_coupon",      limit: 255
  end

  create_table "reserved_teams", force: :cascade do |t|
    t.integer "user_id"
    t.text    "name"
    t.text    "company"
  end

  create_table "seized_opportunities", force: :cascade do |t|
    t.integer  "opportunity_id"
    t.string   "opportunity_type", limit: 255
    t.integer  "user_id"
    t.string   "team_document_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
  end

  create_table "sent_mails", force: :cascade do |t|
    t.integer  "mailable_id"
    t.string   "mailable_type", limit: 255
    t.integer  "user_id"
    t.datetime "sent_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "skills", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",               limit: 255,                 null: false
    t.integer  "endorsements_count",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tokenized",          limit: 255
    t.integer  "weight",                         default: 0
    t.text     "repos"
    t.text     "speaking_events"
    t.text     "attended_events"
    t.boolean  "deleted",                        default: false, null: false
    t.datetime "deleted_at"
  end

  add_index "skills", ["deleted", "user_id"], name: "index_skills_on_deleted_and_user_id", using: :btree
  add_index "skills", ["user_id"], name: "index_skills_on_user_id", using: :btree

  create_table "spam_reports", force: :cascade do |t|
    t.integer  "spammable_id",               null: false
    t.string   "spammable_type", limit: 255, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.string   "website",                  limit: 255
    t.text     "about"
    t.decimal  "total",                                precision: 40, scale: 30, default: 0.0
    t.integer  "size",                                                           default: 0
    t.decimal  "mean",                                 precision: 40, scale: 30, default: 0.0
    t.decimal  "median",                               precision: 40, scale: 30, default: 0.0
    t.decimal  "score",                                precision: 40, scale: 30, default: 0.0
    t.string   "twitter",                  limit: 255
    t.string   "facebook",                 limit: 255
    t.citext   "slug",                                                                              null: false
    t.boolean  "premium",                                                        default: false
    t.boolean  "analytics",                                                      default: false
    t.boolean  "valid_jobs",                                                     default: false
    t.boolean  "hide_from_featured",                                             default: false
    t.string   "preview_code",             limit: 255
    t.string   "youtube_url",              limit: 255
    t.string   "github",                   limit: 255
    t.string   "highlight_tags",           limit: 255
    t.text     "branding"
    t.text     "headline"
    t.text     "big_quote"
    t.string   "big_image",                limit: 255
    t.string   "featured_banner_image",    limit: 255
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
    t.string   "featured_links_title",     limit: 255
    t.text     "blog_feed"
    t.text     "our_challenge"
    t.text     "your_impact"
    t.text     "hiring_tagline"
    t.text     "link_to_careers_page"
    t.string   "avatar",                   limit: 255
    t.integer  "achievement_count",                                              default: 0
    t.integer  "endorsement_count",                                              default: 0
    t.datetime "upgraded_at"
    t.integer  "paid_job_posts",                                                 default: 0
    t.boolean  "monthly_subscription",                                           default: false
    t.text     "stack_list",                                                     default: ""
    t.integer  "number_of_jobs_to_show",                                         default: 2
    t.string   "location",                 limit: 255
    t.integer  "country_id"
    t.string   "name",                     limit: 255
    t.string   "github_organization_name", limit: 255
    t.integer  "team_size"
    t.string   "mongo_id",                 limit: 255
    t.string   "office_photos",                                                  default: [],                    array: true
    t.text     "upcoming_events",                                                default: [],                    array: true
    t.text     "interview_steps",                                                default: [],                    array: true
    t.string   "invited_emails",                                                 default: [],                    array: true
    t.string   "pending_join_requests",                                          default: [],                    array: true
    t.string   "state",                    limit: 255,                           default: "active"
  end

  create_table "teams_account_plans", id: false, force: :cascade do |t|
    t.integer "plan_id"
    t.integer "account_id"
  end

  create_table "teams_accounts", force: :cascade do |t|
    t.integer  "team_id",                           null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "stripe_card_token",     limit: 255, null: false
    t.string   "stripe_customer_token", limit: 255, null: false
    t.integer  "admin_id",                          null: false
    t.datetime "trial_end"
  end

  create_table "teams_links", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "url"
    t.integer  "team_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "teams_locations", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "description"
    t.text     "address"
    t.string   "city",               limit: 255
    t.string   "state_code",         limit: 255
    t.string   "country",            limit: 255
    t.integer  "team_id",                                     null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "points_of_interest",             default: [],              array: true
  end

  create_table "teams_members", force: :cascade do |t|
    t.integer  "team_id",                                     null: false
    t.integer  "user_id",                                     null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "state",       limit: 255, default: "pending"
    t.float    "score_cache"
    t.string   "team_banner", limit: 255
    t.string   "team_avatar", limit: 255
    t.string   "role",        limit: 255, default: "member"
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "token",      limit: 255
    t.string   "secret",     limit: 255
    t.string   "kind",       limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["kind", "user_id"], name: "index_tokens_on_kind_and_user_id", unique: true, using: :btree

  create_table "user_events", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",       limit: 255
    t.text     "data"
    t.datetime "created_at",             default: '2012-03-12 21:01:10'
  end

  create_table "users", force: :cascade do |t|
    t.citext   "username"
    t.string   "name",                          limit: 255
    t.citext   "email"
    t.string   "location",                      limit: 255
    t.string   "old_github_token",              limit: 255
    t.string   "state",                         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter",                       limit: 255
    t.string   "linkedin_legacy",               limit: 255
    t.string   "stackoverflow",                 limit: 255
    t.boolean  "admin",                                     default: false
    t.string   "backup_email",                  limit: 255
    t.integer  "badges_count",                              default: 0
    t.string   "bitbucket",                     limit: 255
    t.string   "codeplex",                      limit: 255
    t.integer  "login_count",                               default: 0
    t.datetime "last_request_at",                           default: '2014-07-23 03:14:36'
    t.datetime "achievements_checked_at",                   default: '1911-08-12 21:49:21'
    t.text     "claim_code"
    t.integer  "github_id"
    t.string   "country",                       limit: 255
    t.string   "city",                          limit: 255
    t.string   "state_name",                    limit: 255
    t.float    "lat"
    t.float    "lng"
    t.integer  "http_counter"
    t.string   "github_token",                  limit: 255
    t.datetime "twitter_checked_at",                        default: '1911-08-12 21:49:21'
    t.string   "title",                         limit: 255
    t.string   "company",                       limit: 255
    t.string   "blog",                          limit: 255
    t.citext   "github"
    t.string   "forrst",                        limit: 255
    t.string   "dribbble",                      limit: 255
    t.text     "specialties"
    t.boolean  "notify_on_award",                           default: true
    t.boolean  "receive_newsletter",                        default: true
    t.string   "zerply",                        limit: 255
    t.string   "linkedin",                      limit: 255
    t.string   "linkedin_id",                   limit: 255
    t.string   "linkedin_token",                limit: 255
    t.string   "twitter_id",                    limit: 255
    t.string   "twitter_token",                 limit: 255
    t.string   "twitter_secret",                limit: 255
    t.string   "linkedin_secret",               limit: 255
    t.datetime "last_email_sent"
    t.string   "linkedin_public_url",           limit: 255
    t.text     "redemptions"
    t.integer  "endorsements_count",                        default: 0
    t.string   "team_document_id",              limit: 255
    t.string   "speakerdeck",                   limit: 255
    t.string   "slideshare",                    limit: 255
    t.datetime "last_refresh_at",                           default: '1970-01-01 00:00:00'
    t.string   "referral_token",                limit: 255
    t.string   "referred_by",                   limit: 255
    t.text     "about"
    t.date     "joined_github_on"
    t.string   "avatar",                        limit: 255
    t.string   "banner",                        limit: 255
    t.datetime "remind_to_invite_team_members"
    t.datetime "activated_on"
    t.string   "tracking_code",                 limit: 255
    t.string   "utm_campaign",                  limit: 255
    t.float    "score_cache",                               default: 0.0
    t.string   "gender",                        limit: 255
    t.boolean  "notify_on_follow",                          default: true
    t.string   "api_key",                       limit: 255
    t.datetime "remind_to_create_team"
    t.datetime "remind_to_create_protip"
    t.datetime "remind_to_create_skills"
    t.datetime "remind_to_link_accounts"
    t.string   "favorite_websites",             limit: 255
    t.text     "team_responsibilities"
    t.string   "team_avatar",                   limit: 255
    t.string   "team_banner",                   limit: 255
    t.string   "stat_name_1",                   limit: 255
    t.string   "stat_number_1",                 limit: 255
    t.string   "stat_name_2",                   limit: 255
    t.string   "stat_number_2",                 limit: 255
    t.string   "stat_name_3",                   limit: 255
    t.string   "stat_number_3",                 limit: 255
    t.float    "ip_lat"
    t.float    "ip_lng"
    t.float    "penalty",                                   default: 0.0
    t.boolean  "receive_weekly_digest",                     default: true
    t.integer  "github_failures",                           default: 0
    t.string   "resume",                        limit: 255
    t.string   "sourceforge",                   limit: 255
    t.string   "google_code",                   limit: 255
    t.boolean  "sales_rep",                                 default: false
    t.string   "visits",                        limit: 255, default: ""
    t.string   "visit_frequency",               limit: 255, default: "rarely"
    t.integer  "pitchbox_id"
    t.boolean  "join_badge_orgs",                           default: false
    t.boolean  "use_social_for_pitchbox",                   default: false
    t.datetime "last_asm_email_at"
    t.datetime "banned_at"
    t.string   "last_ip",                       limit: 255
    t.string   "last_ua",                       limit: 255
    t.integer  "team_id"
  end

  add_index "users", ["linkedin_id"], name: "index_users_on_linkedin_id", unique: true, using: :btree
  add_index "users", ["old_github_token"], name: "index_users_on_github_token", unique: true, using: :btree
  add_index "users", ["team_document_id"], name: "index_users_on_team_document_id", using: :btree
  add_index "users", ["twitter_id"], name: "index_users_on_twitter_id", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_github_organizations", force: :cascade do |t|
    t.string   "login",             limit: 255
    t.string   "company",           limit: 255
    t.string   "blog",              limit: 255
    t.string   "location",          limit: 255
    t.string   "url",               limit: 255
    t.integer  "github_id"
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "users_github_organizations_followers", id: false, force: :cascade do |t|
    t.integer  "organization_id", null: false
    t.integer  "profile_id",      null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users_github_profiles", force: :cascade do |t|
    t.citext   "login",                                         null: false
    t.string   "name",              limit: 255
    t.string   "company",           limit: 255
    t.string   "location",          limit: 255
    t.integer  "github_id"
    t.integer  "user_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "hireable",                      default: false
    t.integer  "followers_count",               default: 0
    t.integer  "following_count",               default: 0
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.datetime "spider_updated_at"
  end

  create_table "users_github_profiles_followers", id: false, force: :cascade do |t|
    t.integer  "follower_id", null: false
    t.integer  "profile_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users_github_repositories", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.text     "description"
    t.string   "full_name",                   limit: 255
    t.string   "homepage",                    limit: 255
    t.boolean  "fork",                                    default: false
    t.integer  "forks_count",                             default: 0
    t.datetime "forks_count_updated_at",                  default: '2014-07-23 03:14:37'
    t.integer  "stargazers_count",                        default: 0
    t.datetime "stargazers_count_updated_at",             default: '2014-07-23 03:14:37'
    t.string   "language",                    limit: 255
    t.integer  "followers_count",                         default: 0,                     null: false
    t.integer  "github_id",                                                               null: false
    t.integer  "owner_id"
    t.integer  "organization_id"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  create_table "users_github_repositories_contributors", id: false, force: :cascade do |t|
    t.integer  "repository_id", null: false
    t.integer  "profile_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users_github_repositories_followers", id: false, force: :cascade do |t|
    t.integer  "repository_id", null: false
    t.integer  "profile_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
