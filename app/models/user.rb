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
#  role                          :string(255)      default("user")
#

require 'net_validators'

class User < ActiveRecord::Base
  include ActionController::Caching::Fragments
  include NetValidators
  include UserApi
  include UserAward
  include UserBadge
  include UserEndorser
  include UserEventConcern
  include UserFacts
  include UserFollowing
  include UserGithub
  include UserLinkedin
  include UserOauth
  include UserProtip
  include UserRedis
  include UserRedisKeys
  include UserTeam
  include UserTrack
  include UserTwitter
  include UserViewer
  include UserVisit
  include UserSearch
  include UserStateMachine
  include UserJob

  attr_protected :admin, :role, :id, :github_id, :twitter_id, :linkedin_id, :api_key

  mount_uploader :avatar, AvatarUploader
  mount_uploader :resume, ResumeUploader

  mount_uploader :banner, BannerUploader
  process_in_background :banner, ResizeTiltShiftBannerJob

  RESERVED = %w{
    achievements
    admin
    administrator
    api
    contact_us
    emails
    faq
    privacy_policy
    root
    superuser
    teams
    tos
    usernames
    users
  }


  REGISTRATION = 'registration'
  PENDING      = 'pending'
  ACTIVE       = 'active'

  acts_as_followable
  acts_as_follower

  VALID_USERNAME_RIGHT_WAY = /^[a-z0-9]+$/
  VALID_USERNAME           = /^[^\.]+$/
  validates :username,
            exclusion: {in: RESERVED, message: "is reserved"},
            format: {with: VALID_USERNAME, message: "must not contain a period"},
            presence: true,
            uniqueness: true

  validates_presence_of :email
  validates_presence_of :location
  validates :email, email: true, if: :not_active?

  has_many :badges, order: 'created_at DESC'
  has_many :followed_teams
  has_many :user_events
  has_many :skills, order: "weight DESC"
  has_many :endorsements, foreign_key: 'endorsed_user_id'
  has_many :endorsings, foreign_key: 'endorsing_user_id', class_name: 'Endorsement'
  has_many :protips, dependent: :destroy
  has_many :likes
  has_many :comments

  has_one :github_profile  , class_name: 'Users::Github::Profile', dependent: :destroy
  has_many :github_repositories, through: :github_profile , source: :repositories

  belongs_to :team, class_name: 'Team'
  has_one :membership, class_name: 'Teams::Member' #current_team
  has_many :memberships, class_name: 'Teams::Member', dependent: :destroy

  has_one :picture, dependent: :destroy

  geocoded_by :location, latitude: :lat, longitude: :lng, country: :country, state_code: :state_name
  # FIXME: Move to background job
  after_validation :geocode_location, if: :location_changed? unless Rails.env.test?

  def near
    User.near([lat, lng])
  end

  scope :top, ->(limit = 10) { order("badges_count DESC").limit(limit) }
  scope :no_emails_since, ->(date) { where("last_email_sent IS NULL OR last_email_sent < ?", date) }
  scope :receives_activity,  -> { where(notify_on_award: true) }
  scope :receives_newsletter, -> { where(receive_newsletter: true) }
  scope :receives_digest, -> { where(receive_weekly_digest: true) }
  scope :with_tokens, -> { where('github_token IS NOT NULL') }
  scope :autocomplete, ->(filter) {
    filter = "#{filter.upcase}%"
    where("upper(username) LIKE ? OR upper(twitter) LIKE ? OR upper(github) LIKE ? OR upper(name) LIKE ?", filter, filter, filter, "%#{filter}").order("name ASC")
  }
  scope :admins, -> { where(role: 'admin') }
  scope :active, -> { where(state: ACTIVE) }
  scope :pending, -> { where(state: PENDING) }
  scope :abandoned, -> { where(state: 'registration').where('created_at < ?', 1.hour.ago) }
  scope :random, -> (limit = 1) { active.where('badges_count > 1').order('RANDOM()').limit(limit) }


  def self.find_by_provider_username(username, provider)
    return nil if username.nil?
    return self.find_by_username(username) if provider == ''
    unless %w{twitter linkedin github}.include?(provider)
      raise "Unkown provider type specified, unable to find user by username"
    end
    where(["UPPER(#{provider}) = UPPER(?)", username]).first
  end

  def display_name
    name.presence || username
  end

  def short_name
    display_name.split(' ').first
  end

  def achievements_checked?
    !achievements_checked_at.nil? && achievements_checked_at > 1.year.ago
  end

  def brief
      about
  end


  def can_unlink_provider?(provider)
    self.respond_to?("clear_#{provider}!") && self.send("#{provider}_identity") && num_linked_accounts > 1
  end

  LINKABLE_PROVIDERS= %w(twitter linkedin github)

  def num_linked_accounts
    LINKABLE_PROVIDERS.map { |provider| self.send("#{provider}_identity") }.compact.count
  end

  def deleted_skill?(skill_name)
    Skill.deleted?(self.id, skill_name)
  end

  def tokenized_lanyrd_tags
    lanyrd_facts.flat_map { |fact| fact.tags }.compact.map { |tag| Skill.tokenize(tag) }
  end

  def last_modified_at
    achievements_checked_at || updated_at
  end

  def geocode_location
    do_lookup(false) do |o, rs|
      geo             = rs.first
      self.lat        = geo.latitude
      self.lng        = geo.longitude
      self.country    = geo.country
      self.state_name = geo.state
      self.city       = geo.city
    end
    rescue Exception => ex
  end

  def activity_stats(since=Time.at(0), full=false)
    { profile_views:  self.total_views(since),
      protips_count:  self.protips.where('protips.created_at > ?', since).count,
      protip_upvotes: self.protips.joins("inner join likes on likes.likable_id = protips.id").where("likes.likable_type = 'Protip'").where('likes.created_at > ?', since).count,
      followers:      followers_since(since).count,
      endorsements:   full ? endorsements_since(since).count : 0,
      protips_views:  full ? self.protips.collect { |protip| protip.total_views(since) }.reduce(0, :+) : 0
    }
  end

  def activity
    Event.user_activity(self, nil, nil, -1)
  end

  def score
    calculate_score! if score_cache == 0
    score_cache
  end

  def penalize!(amount=(((team && team.members.size) || 6) / 6.0)*activitiy_multipler)
    self.penalty = amount
    self.calculate_score!
  end

  def calculate_score!
    score            = ((endorsers.count / 6.0) + (achievement_score) + (times_spoken / 1.50) + (times_attended / 4.0)) * activitiy_multipler
    self.score_cache = [score - penalty, 0.0].max
    save!
  rescue => ex
    Rails.logger.error("Failed cacluating score for #{username} due to '#{ex}' >>\n#{ex.backtrace.join("\n  ")}")
  end

  def like_value
    (score || 0) > 0 ? score : 1
  end

  def activitiy_multipler
    return 1 if latest_activity_on.nil?
    if latest_activity_on > 1.month.ago
      1.2
    else
      1
    end
  end

  def latest_activity_on
    @latest_activity_on ||= facts.collect(&:relevant_on).compact.max
  end

  def speciality_tags
    (specialties || '').split(',').collect(&:strip).compact
  end

  def networks_based_on_skills
    self.skills.flat_map { |skill| Network.all_with_tag(skill.name) }.uniq
  end

  #This is a temporary method as we migrate to the new 1.0 profile
  def migrate_to_skills!
    badges.each do |b|
      if b.badge_class.respond_to?(:skill)
        add_skill(b.badge_class.skill)
      end
    end

    speciality_tags.each do |tag|
      add_skill(tag)
    end

    endorsements.each do |e|
      add_skill(e.specialty)
      skill = skill_for(e.specialty)
      if skill
        e.skill = skill
        e.save!
      end
    end

    update_attributes!(endorsements_count: endorsements.size)
  end

  def add_skill(name)
    return nil if Sanitize.clean(name).to_s.strip.blank?
    ((skill = skill_for(name)) && skill.apply_facts && skill) || (skill = skills.create!(name: name))
  end

  def skill_for(name)
    tokenized_skill = Skill.tokenize(name)
    skills.detect { |skill| skill.tokenized == tokenized_skill }
  end

  private

  before_save :destroy_badges

  def destroy_badges
    unless @badges_to_destroy.nil?
      self.badges.where(badge_class_name: @badges_to_destroy).destroy_all
      @badges_to_destroy = nil
    end
  end

  before_create do
    self.referral_token ||= SecureRandom.hex(8)
  end

  after_save :refresh_dependencies

  def refresh_dependencies
    if username_changed? or avatar_changed? or team_id_changed?
      refresh_protips
    end
  end

  after_save :manage_github_orgs
  after_destroy :remove_all_github_badges

  def manage_github_orgs
    if join_badge_orgs_changed?
      if join_badge_orgs?
        add_all_github_badges
      else
        remove_all_github_badges
      end
    end
  end
end
