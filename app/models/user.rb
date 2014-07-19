require "net_validators"

class User < ActiveRecord::Base
  include ActionController::Caching::Fragments
  extend ResqueSupport::ActiveModel
  include ResqueSupport::Basic
  include NetValidators

  attr_protected :admin, :id, :github_id, :twitter_id, :linkedin_id, :api_key

  mount_uploader :avatar, AvatarUploader
  mount_uploader :banner, BannerUploader
  mount_uploader :resume, ResumeUploader
  process_in_background :banner, ResizeTiltShiftBanner

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

  BLANK_PROFILE_URL = 'blank-mugshot.png'

  REGISTRATION = 'registration'
  PENDING      = 'pending'
  ACTIVE       = 'active'
  serialize :redemptions, Array

  acts_as_followable
  acts_as_follower

  before_validation { |u| u && u.username && u.username.downcase! }
  before_validation :correct_ids
  before_validation :correct_urls

  VALID_USERNAME_RIGHT_WAY = /^[a-z0-9]+$/
  VALID_USERNAME           = /^[^\.]+$/
  validates :username,
    exclusion: { in: RESERVED, message: "is reserved" },
    format:    { with: VALID_USERNAME, message: "must not contain a period" }

  validates_uniqueness_of :username #, :case_sensitive => false, :on => :create

  validates_presence_of :username
  validates_presence_of :email
  validates_presence_of :location
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, if: :not_active?

  has_many :badges, order: 'created_at DESC', dependent: :delete_all
  has_many :highlights, order: 'created_at DESC', dependent: :delete_all
  has_many :followed_teams, dependent: :delete_all
  has_many :user_events
  has_many :skills, order: "weight DESC", dependent: :delete_all
  has_many :endorsements, foreign_key: 'endorsed_user_id', dependent: :delete_all
  has_many :endorsings, foreign_key: 'endorsing_user_id', class_name: Endorsement.name, dependent: :delete_all
  has_many :protips, dependent: :delete_all
  has_many :likes
  has_many :comments, dependent: :delete_all

  geocoded_by :location, latitude: :lat, longitude: :lng, country: :country, state_code: :state_name
  after_validation :geocode_location, if: :location_changed? unless Rails.env.test?

  def near
    User.near([lat, lng])
  end

  scope :top, lambda { |num| order("badges_count DESC").limit(num || 10) }
  scope :no_emails_since, lambda { |date| where("last_email_sent IS NULL OR last_email_sent < ?", date) }
  scope :receives_activity, where(notify_on_award: true)
  scope :receives_newsletter, where(receive_newsletter: true)
  scope :receives_digest, where(receive_weekly_digest: true)
  scope :with_tokens, where("github_token IS NOT NULL")
  scope :on_team, where("team_document_id IS NOT NULL")
  scope :not_on_team, where("team_document_id IS NULL")
  scope :autocomplete, lambda { |filter|
    filter = "#{filter.upcase}%"
    where("upper(username) LIKE ? OR upper(twitter) LIKE ? OR upper(github) LIKE ? OR upper(name) LIKE ?", filter, filter, filter, "%#{filter}").order("name ASC")
  }
  scope :admins, where(admin: true)

  class << self
    def bootstrap(username, token = nil)
      user          = User.new(github: username, github_token: token)
      user.username = username
      profile       = user.refresh_github!
      user.email    = profile[:email] || 'something@test.com'
      user.location = profile[:location] || 'Unknown'
      user.save!

      user.build_github_facts
      user
    end

    def with_token(token)
      where(github_token: token).first
    end

    def username_in(usernames)
      where(["UPPER(username) in (?)", usernames.collect(&:upcase)])
    end

    def with_username(username, provider = :username)
      return nil if username.nil?
      sql_injection_safe_where_clause = case provider.to_s
                                        when 'username', ''
                                          'username'
                                        when 'linkedin'
                                          'linkedin'
                                        when 'twitter'
                                          'twitter'
                                        when 'github'
                                          'github'
                                        else
                                          #A user could malicously pass in a provider, thats why we do the string matching above
                                          raise "Unkown provider type specified, unable to find user by username"
                                        end
      where(["UPPER(#{sql_injection_safe_where_clause}) = UPPER(?)", username]).first
    end

    def with_username_or_email(username_or_email)
      where(["UPPER(username) = ? OR email like ?", username_or_email.upcase, username_or_email]).first
    end

    def stalest_github_profile(limit = nil)
      query = active.order("achievements_checked_at ASC")
      limit ? query.limit(limit) : query
    end

    def active
      where(state: ACTIVE)
    end

    def pending
      where(state: PENDING)
    end

    def abandoned
      where(state: 'registration').where('created_at < ?', 1.hour.ago)
    end

    def random(limit = 1)
      active.where("badges_count > 1").order("Random()").limit(limit)
    end

    def for_omniauth(auth)
      if user = find_with_oauth(auth)
        user.apply_oauth(auth)
        user.save! if user.changed?
        return user
      else
        user = new(
          name:          auth[:info][:name],
          email:         auth[:info][:email],
          backup_email:  auth[:info][:email],
          location:      location_from(auth),
          thumbnail_url: thumbnail_url_for(auth))
        user.apply_oauth(auth)
        user.username = auth[:info][:nickname]
        return user
      end
    end

    def find_with_oauth(oauth)
      case oauth[:provider]
      when 'github'
        github_scope = (oauth[:uid] ? where(github_id: oauth[:uid]) : where(github: oauth[:info][:nickname]))
        raise "Not a unique github credential #{oauth[:uid] || oauth[:info][:nickname]}" if github_scope.count > 1
        return github_scope.first
      when 'linkedin'
        linkedin_scope = where(linkedin_id: oauth[:uid])
        raise "Not a unique linkedin credential #{oauth[:uid]}" if linkedin_scope.count > 1
        return linkedin_scope.first
      when 'twitter'
        twitter_scope = where(twitter_id: oauth[:uid])
        raise "Not a unique twitter credential #{oauth[:uid]}" if twitter_scope.count > 1
        return twitter_scope.first
      when 'developer'
        fail 'Developer Strategy must not be used in production.' if Rails.env.production?
        developer_scope = where(email: oauth[:uid])
        raise "Looks like there's duplicate users for the email '#{oauth[:uid]}'. Check user ids: #{developer_scope.map(&:id).join(', ')}" if developer_scope.count > 1
        return developer_scope.first
      else
        raise "Unexpected provider: #{oauth[:provider]}"
      end
    end

    def location_from(oauth)
      if oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][:location]
        (oauth[:extra][:raw_info][:location].is_a?(Hash) && oauth[:extra][:raw_info][:location][:name]) || oauth[:extra][:raw_info][:location]
      elsif oauth[:info]
        oauth[:info][:location]
      end
    end

    def thumbnail_url_for(oauth)
      if github = oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][:gravatar_id]
        "https://secure.gravatar.com/avatar/#{oauth[:extra][:raw_info][:gravatar_id]}"
      elsif oauth[:info]
        if oauth['provider'] == 'twitter'
          oauth[:extra][:raw_info][:profile_image_url_https]
        else
          oauth[:info][:image]
        end
      end
    end

    def all_tokens
      with_tokens.select("github_token").collect(&:github_token)
    end

    def signups_by_day
      find_by_sql("SELECT to_char(created_at, 'MM DD') AS day, count(*) AS signups from users group by to_char(created_at, 'MM DD') order by to_char(created_at, 'MM DD')").collect { |u| [u.day, u.signups] }
    end

    def signups_by_hour
      find_by_sql("SELECT to_char(created_at, 'HH24') AS hour, count(*) AS signups from users where created_at > NOW() - interval '24 hours' group by to_char(created_at, 'HH24') order by to_char(created_at, 'HH24')").collect { |u| [u.hour, u.signups] }
    end

    def signups_by_month
      find_by_sql("SELECT to_char(created_at, 'MON') AS day, count(*) AS signups from users group by to_char(created_at, 'MON') order by to_char(created_at, 'MON') DESC").collect { |u| [u.day, u.signups] }
    end

    def repeat_visits_by_count
      find_by_sql("SELECT login_count, count(*) AS visits from users group by login_count").collect { |u| [u.login_count, u.visits] }
    end

    def monthly_growth
      prior = where("created_at < ?", 31.days.ago).count
      month = where("created_at >= ?", 31.days.ago).count
      ((month.to_f / prior.to_f) * 100)
    end

    def weekly_growth
      prior = where("created_at < ?", 7.days.ago).count
      week  = where("created_at >= ?", 7.days.ago).count
      ((week.to_f / prior.to_f) * 100)
    end

    def most_active_by_country(since=1.week.ago)
      select('country, count(distinct(id))').where('last_request_at > ?', since).group(:country).order('count(distinct(id)) DESC')
    end
  end

  def banned?
    banned_at.present?
  end

  def oldest_achievement_since_last_visit
    badges.where("badges.created_at > ?", last_request_at).order('badges.created_at ASC').last
  end

  def correct_ids
    [:stackoverflow, :slideshare].each do |social_id|
      if self.try(social_id) =~ /^https?:.*\/([\w_\-]+)\/([\w\-]+|newsfeed)?/
        self.send("#{social_id}=", $1)
      end
    end
  end

  def correct_urls
    self.favorite_websites = self.favorite_websites.split(",").collect do |website|
      correct_url(website.strip)
    end.join(",") unless self.favorite_websites.nil?
  end

  def company_name
    team.try(:name) || company
  end

  def profile_url
    if !avatar.blank?
      avatar_url
    elsif thumbnail_url.blank?
      BLANK_PROFILE_URL
    else
      thumbnail_url
    end
  end

  def apply_oauth(oauth)
    case oauth[:provider]
    when 'github'
      self.github           = oauth[:info][:nickname]
      self.github_id        = oauth[:uid]
      self.github_token     = oauth[:credentials][:token]
      self.blog             = oauth[:info][:urls][:Blog] if oauth[:info][:urls] && self.blog.blank?
      self.joined_github_on = extract_joined_on(oauth) if self.joined_github_on.blank?
    when 'linkedin'
      self.linkedin_id         = oauth[:uid]
      self.linkedin_public_url = oauth[:info][:urls][:public_profile] if oauth[:info][:urls]
      self.linkedin_token      = oauth[:credentials][:token]
      self.linkedin_secret     = oauth[:credentials][:secret]
    when 'twitter'
      self.twitter           = oauth[:info][:nickname]
      self.twitter_id        = oauth[:uid]
      self.twitter_token     = oauth[:credentials][:token]
      self.twitter_secret    = oauth[:credentials][:secret]
      self.about             = extract_from_oauth_extras(:description, oauth) if self.about.blank?
      self.joined_twitter_on = extract_joined_on(oauth) if self.joined_twitter_on.blank?
    when 'developer'
      logger.debug "Using the Developer Strategy for OmniAuth"
      logger.ap oauth, :debug
    else
      raise "Unexpected provider: #{oauth[:provider]}"
    end
  end

  def extract_joined_on(oauth)
    val = extract_from_oauth_extras(:created_at, oauth)
    return Date.parse(val) if val
  end

  def extract_from_oauth_extras(field, oauth)
    oauth[:extra][:raw_info][field] if oauth[:extra] && oauth[:extra][:raw_info] && oauth[:extra][:raw_info][field]
  end

  def can_be_refreshed?
    (achievements_checked_at.nil? || achievements_checked_at < 1.hour.ago)
  end

  def display_name
    name.blank? ? username : name
  end

  def short_name
    display_name.split(' ').first
  end

  def has_badges?
    !badges.empty?
  end

  def has_badge?(badge_class)
    badges.collect(&:badge_class_name).include?(badge_class.name)
  end

  def achievements_checked?
    !achievements_checked_at.nil? && achievements_checked_at > 1.year.ago
  end

  def twitter_profile
    @twitter_profile ||= TwitterProfile.for_username(twitter) unless twitter.blank?
  end

  def brief
    if about.blank?
      if highlight = highlights.last
        highlight.description
      else
        nil
      end
    else
      about
    end
  end

  def team_ids
    [team_document_id]
  end

  def team
    @team ||= team_document_id && Team.find(team_document_id)
  rescue Mongoid::Errors::DocumentNotFound
    #readonly issue in follows/_user partial from partial iterator
    User.connection.execute("UPDATE users set team_document_id = NULL where id = #{self.id}")
    @team = nil
  end

  def on_premium_team?
    team.try(:premium?) || false
  end

  def following_team?(team)
    followed_teams.collect(&:team_document_id).include?(team.id.to_s)
  end

  def follow_team!(team)
    followed_teams.create!(team_document_id: team.id.to_s)
    generate_event(team: team)
  end

  def unfollow_team!(team)
    followed_teams = self.followed_teams.where(team_document_id: team.id.to_s).all
    followed_teams.each(&:destroy)
  end

  def teams_being_followed
    Team.find(followed_teams.collect(&:team_document_id)).sort { |x, y| y.score <=> x.score }
  end

  def on_team?
    !team_document_id.nil?
  end

  def team_member_of?(user)
    on_team? && self.team_document_id == user.team_document_id
  end

  def belongs_to_team?(team = nil)
    if self.team && team
      self.team.id.to_s == team.id.to_s
    else
      !team_document_id.blank?
    end
  end

  def complete_registration!(opts={})
    update_attribute(:state, PENDING)
    Resque.enqueue(ActivateUser, self.username)
    Resque.enqueue(AnalyzeUser, self.username)
  end

  def activate!
    touch(:activated_on)
    update_attribute(:state, ACTIVE)
  end

  def unregistered?
    state == nil
  end

  def not_active?
    !active?
  end

  def active?
    state == ACTIVE
  end

  def pending?
    state == PENDING
  end

  def total_achievements
    badges_count
  end

  def has_beta_access?
    admin? || beta_access
  end

  def award(badge)
    new_badge = self.badges.of_type(badge).first || self.badges.build(badge_class_name: badge.class.name)
  end

  def add_github_badge(badge)
    GithubBadge.new.add(badge, self.github)
  end

  def remove_github_badge(badge)
    GithubBadge.new.remove(badge, self.github)
  end

  def add_all_github_badges
    enqueue(GithubBadgeOrg, self.username, :add)
  end

  def remove_all_github_badges
    enqueue(GithubBadgeOrg, self.username, :remove)
  end

  def award_and_add_skill(badge)
    award badge
    if badge.respond_to? :skill
      add_skill(badge.skill)
    end
  end

  def assign_badges(new_badges)
    new_badge_classes = new_badges.map { |b| b.class.name }
    old_badge_classes = self.badges.map(&:badge_class_name)

    @badges_to_destroy = old_badge_classes - new_badge_classes

    new_badges.each do |badge|
      award_and_add_skill(badge)
    end
  end

  def to_csv
    [
      display_name,
      "\"#{location}\"",
      "https://coderwall.com/#{username}",
      "https://twitter.com/#{twitter}",
      "https://github.com/#{github}",
      linkedin_public_url,
      skills.collect(&:name).join(' ')
    ].join(',')
  end

  def public_hash(full=false)
    hash = { username:     username,
             name:         display_name,
             location:     location,
             endorsements: endorsements.count,
             team:         team_document_id,
             accounts:     { github: github },
             badges:       badges_hash = [] }
    badges.each do |badge|
      badges_hash << {
        name:        badge.display_name,
        description: badge.description,
        created:     badge.created_at,
        badge:       block_given? ? yield(badge) : badge
      }
    end
    if full
      hash[:title]              = title
      hash[:company]            = company
      hash[:specialities]       = speciality_tags
      hash[:thumbnail]          = thumbnail_url
      hash[:accomplishments]    = highlights.collect(&:description)
      hash[:accounts][:twitter] = twitter
    end
    hash
  end

  def facts
    @facts ||= begin
                 user_identites = [linkedin_identity, bitbucket_identity, lanyrd_identity, twitter_identity, github_identity, speakerdeck_identity, slideshare_identity, id.to_s].compact
                 Fact.where(owner: user_identites.collect(&:downcase)).all
               end
  end

  def clear_facts!
    facts.each { |fact| fact.destroy }
    skills.each { |skill| skill.apply_facts && skill.save }
    self.github_failures = 0
    save!
    Resque.enqueue(RefreshUser, username, true)
  end

  def clear_github!
    self.github_id        = nil
    self.github           = nil
    self.github_token     = nil
    self.joined_github_on = nil
    self.github_failures  = 0
    save!
  end

  def clear_linkedin!
    self.linkedin            = nil
    self.linkedin_id         = nil
    self.linkedin_token      = nil
    self.linkedin_secret     = nil
    self.linkedin_public_url = nil
    self.linkedin_legacy     = nil
    save!
  end

  def clear_twitter!
    self.twitter           = nil
    self.twitter_token     = nil
    self.twitter_secret    = nil
    self.joined_twitter_on = nil
    save!
  end

  def can_unlink_provider?(provider)
    self.respond_to?("clear_#{provider}!") && self.send("#{provider}_identity") && num_linked_accounts > 1
  end

  LINKABLE_PROVIDERS= %w(twitter linkedin github)

  def num_linked_accounts
    LINKABLE_PROVIDERS.map { |provider| self.send("#{provider}_identity") }.compact.count
  end

  def linkedin_identity
    "linkedin:#{linkedin_token}::#{linkedin_secret}" if linkedin_token
  end

  def twitter_identity
    "twitter:#{twitter}" if twitter
  end

  def bitbucket_identity
    "bitbucket:#{bitbucket}" unless bitbucket.blank?
  end

  def lanyrd_identity
    "lanyrd:#{twitter}" if twitter
  end

  def github_identity
    "github:#{github}" if github
  end

  def speakerdeck_identity
    "speakerdeck:#{speakerdeck}" if speakerdeck
  end

  def slideshare_identity
    "slideshare:#{slideshare}" if slideshare
  end

  def build_facts(all)
    since = (all ? Time.at(0) : self.last_refresh_at)
    build_github_facts(since)
    build_lanyrd_facts
    build_linkedin_facts
    build_bitbucket_facts
    build_speakerdeck_facts
    build_slideshare_facts
  end

  def build_speakerdeck_facts
    Speakerdeck.new(speakerdeck).facts if speakerdeck_identity
  end

  def build_slideshare_facts
    Slideshare.new(slideshare).facts if slideshare_identity
  end

  def build_github_facts(since=Time.at(0))
    GithubProfile.for_username(github, since).facts if github_identity and github_failures == 0
  end

  def build_linkedin_facts
    LinkedInStream.new(linkedin_token + '::' + linkedin_secret).facts if linkedin_identity
  rescue => e
    logger.error(e.message + "\n  " + e.backtrace.join("\n  "))
  end

  def build_lanyrd_facts
    Lanyrd.new(twitter).facts if lanyrd_identity
  end

  def build_bitbucket_facts
    Bitbucket::V1.new(bitbucket).update_facts! unless bitbucket.blank?
  end

  def check_achievements!(badge_list = Badges.all)
    BadgeBase.award!(self, badge_list)
    touch(:achievements_checked_at)
    save!
  end

  def add_skills_for_unbadgified_facts
    add_skills_for_repo_facts!
    add_skills_for_lanyrd_facts!
  end

  def add_skills_for_repo_facts!
    repo_facts.each do |fact|
      fact.metadata[:languages].try(:each) do |language|
        unless self.deleted_skill?(language)
          skill = add_skill(language)
          skill.save
        end
      end unless fact.metadata[:languages].nil?
    end
  end

  def add_skills_for_lanyrd_facts!
    tokenized_lanyrd_tags.each do |lanyrd_tag|
      if self.skills.any?
        skill = skill_for(lanyrd_tag)
        skill.apply_facts unless skill.nil?
      else
        skill = add_skill(lanyrd_tag)
      end
      skill.save unless skill.nil?
    end
  end

  def deleted_skill?(skill_name)
    Skill.deleted?(self.id, skill_name)
  end

  def repo_facts
    self.facts.select { |fact| fact.tagged?('personal', 'repo', 'original') }
  end

  def lanyrd_facts
    self.facts.select { |fact| fact.tagged?('lanyrd') }
  end

  def tokenized_lanyrd_tags
    lanyrd_facts.collect { |fact| fact.tags }.flatten.compact.map { |tag| Skill.tokenize(tag) }
  end

  def last_modified_at
    achievements_checked_at || updated_at
  end

  def last_badge_awarded_at
    badge = badges.order('created_at DESC').first
    badge.created_at if badge
  end

  def badges_since_last_visit
    badges.where('created_at > ?', last_request_at).count
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
    Rails.logger.error("Failed geolocating '#{location}': #{ex.message}")  if ENV['DEBUG']
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

  def upvoted_protips
    Protip.where(id: Like.where(likable_type: "Protip").where(user_id: self.id).select(:likable_id).map(&:likable_id))
  end

  def upvoted_protips_public_ids
    upvoted_protips.select(:public_id).map(&:public_id)
  end

  def followers_since(since=Time.at(0))
    self.followers_by_type(User.name).where('follows.created_at > ?', since)
  end

  def activity
    Event.user_activity(self, nil, nil, -1)
  end

  def refresh_github!
    unless github.blank?
      load_github_profile
    end
  end

  def achievement_score
    badges.collect(&:weight).sum
  end

  def score
    calculate_score! if score_cache == 0
    score_cache
  end

  def team_members
    User.where(team_document_id: self.team_document_id.to_s)
  end

  def team_member_ids
    User.select(:id).where(team_document_id: self.team_document_id.to_s).map(&:id)
  end

  def penalize!(amount=(((team && team.team_members.size) || 6) / 6.0)*activitiy_multipler)
    self.penalty = amount
    self.calculate_score!
  end

  def calculate_score!
    score            = ((endorsers.count / 6.0) + (achievement_score) + (times_spoken / 1.50) + (times_attended / 4.0)) * activitiy_multipler
    self.score_cache = [score - penalty, 0.0].max
    save!
  rescue
    Rails.logger.error "Failed cacluating score for #{username}"   if ENV['DEBUG']
  end

  def like_value
    (score || 0) > 0 ? score : 1
  end

  def times_spoken
    facts.select { |fact| fact.tagged?("event", "spoke") }.count
  end

  def times_attended
    facts.select { |fact| fact.tagged?("event", "attended") }.count
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

  def achievements_unlocked_since_last_visit
    self.badges.where("badges.created_at > ?", last_request_at).reorder('badges.created_at ASC')
  end

  def endorsements_unlocked_since_last_visit
    endorsements_since(last_request_at)
  end

  def endorsements_since(since=Time.at(0))
    self.endorsements.where("endorsements.created_at > ?", since).order('endorsements.created_at ASC')
  end

  def endorsers(since=Time.at(0))
    User.where(id: self.endorsements.select('distinct(endorsements.endorsing_user_id), endorsements.created_at').where('endorsements.created_at > ?', since).map(&:endorsing_user_id))
  end

  def activity_since_last_visit?
    (achievements_unlocked_since_last_visit.count + endorsements_unlocked_since_last_visit.count) > 0
  end

  def endorse(user, specialty)
    user.add_skill(specialty).endorsed_by(self)
  end

  def repo_cache_key
    username
  end

  def daily_cache_key
    "#{username}/#{Date.today.to_time.to_i}"
  end

  def timeline_key
    @timeline_key ||= "user:#{id}:timeline"
  end

  def impressions_key
    "user:#{id}:impressions"
  end

  def user_views_key
    "user:#{id}:views"
  end

  def user_anon_views_key
    "user:#{id}:views:anon"
  end

  def viewed_by(viewer)
    epoch_now = Time.now.to_i
    REDIS.incr(impressions_key)
    if viewer.is_a?(User)
      REDIS.zadd(user_views_key, epoch_now, viewer.id)
      generate_event(viewer: viewer.username)
    else
      REDIS.zadd(user_anon_views_key, epoch_now, viewer)
      count = REDIS.zcard(user_anon_views_key)
      REDIS.zremrangebyrank(user_anon_views_key, -(count - 100), -1) if count > 100
    end
  end

  def viewers(since=0)
    epoch_now  = Time.now.to_i
    viewer_ids = REDIS.zrevrangebyscore(user_views_key, epoch_now, since)
    User.where(id: viewer_ids).all
  end

  def viewed_by_since?(user_id, since=0)
    epoch_now   = Time.now.to_i
    views_since = Hash[*REDIS.zrevrangebyscore(user_views_key, epoch_now, since, withscores: true)]
    !views_since[user_id.to_s].nil?
  end

  def total_views(epoch_since = 0)
    if epoch_since.to_i == 0
      REDIS.get(impressions_key).to_i
    else
      epoch_now   = Time.now.to_i
      epoch_since = epoch_since.to_i
      REDIS.zcount(user_views_key, epoch_since, epoch_now) + REDIS.zcount(user_anon_views_key, epoch_since, epoch_now)
    end
  end

  def generate_event(options={})
    event_type = self.event_type(options)
    enqueue(GenerateEvent, event_type, event_audience(event_type, options), self.to_event_hash(options), 30.seconds)
  end

  def subscribed_channels
    Audience.to_channels(Audience.user(self.id))
  end

  def event_audience(event_type, options={})
    if event_type == :profile_view
      Audience.user(self.id)
    elsif event_type == :followed_team
      Audience.team(options[:team].try(:id))
    end
  end

  def to_event_hash(options={})
    event_hash = { user: { username: options[:viewer] || self.username } }
    if options[:viewer]
      event_hash[:views] = total_views
    elsif options[:team]
      event_hash[:follow] = { followed: options[:team].try(:name), follower: self.try(:name) }
    end
    event_hash
  end

  def event_type(options={})
    if options[:team]
      :followed_team
    else
      :profile_view
    end
  end

  def build_github_proptips_fast
    repos = followed_repos(since=2.months.ago)
    repos.each do |repo|
      Importers::Protips::GithubImporter.import_from_follows(repo.description, repo.link, repo.date, self)
    end
  end

  def build_repo_followed_activity!(refresh=false)
    REDIS.zremrangebyrank(followed_repo_key, 0, Time.now.to_i) if refresh
    epoch_now  = Time.now.to_i
    first_time = refresh || REDIS.zcount(followed_repo_key, 0, epoch_now) <= 0
    links      = GithubOld.new.activities_for(self.github, (first_time ? 20 : 1))
    links.each do |link|
      link[:user_id] = self.id
      REDIS.zadd(followed_repo_key, link[:date].to_i, link.to_json)
      Importers::Protips::GithubImporter.import_from_follows(link[:description], link[:link], link[:date], self)
    end
  rescue RestClient::ResourceNotFound
    Rails.logger.warn("Unable to get activity for github #{github}")   if ENV['DEBUG']
    []
  end

  def destroy_github_cache
    GithubRepo.where('owner.github_id' => github_id).destroy if github_id
    GithubProfile.where('login' => github).destroy if github
  end

  def track_user_view!(user)
    track!("viewed user", user_id: user.id, username: user.username)
  end

  def track_signin!
    track!("signed in")
  end

  def track_viewed_self!
    track!("viewed self")
  end

  def track_team_view!(team)
    track!("viewed team", team_id: team.id.to_s, team_name: team.name)
  end

  def track_protip_view!(protip)
    track!("viewed protip", protip_id: protip.public_id, protip_score: protip.score)
  end

  def track_opportunity_view!(opportunity)
    track!("viewed opportunity", opportunity_id: opportunity.id, team: opportunity.team_document_id)
  end

  def track!(name, data = {})
    user_events.create!(name: name, data: data)
  end

  def teams_nearby
    @teams_nearby ||= nearbys(50).collect { |u| u.team rescue nil }.compact.uniq
  end

  def followers_key
    "user:#{id}:followers"
  end

  def build_follow_list!
    if twitter_id
      REDIS.del(followers_key)
      people_user_is_following = Twitter.friend_ids(twitter_id.to_i)
      people_user_is_following.each do |id|
        REDIS.sadd(followers_key, id)
        if user = User.where(twitter_id: id.to_s).first
          self.follow(user)
        end
      end
    end
  end

  def follow(user)
    super(user) rescue ActiveRecord::RecordNotUnique
  end

  def member_of?(network)
    self.following?(network)
  end

  def following_users_ids
    self.following_users.select(:id).map(&:id)
  end

  def following_teams_ids
    self.followed_teams.map(&:team_document_id)
  end

  def following_team_members_ids
    User.select(:id).where(team_document_id: self.following_teams_ids).map(&:id)
  end

  def following_networks_ids
    self.following_networks.select(:id).map(&:id)
  end

  def following_networks_tags
    self.following_networks.map(&:tags).uniq
  end

  def following
    @following ||= begin
                     ids = REDIS.smembers(followers_key)
                     User.where(twitter_id: ids).order("badges_count DESC").limit(10)
                   end
  end

  def following_in_common(user)
    @following_in_common ||= begin
                               ids = REDIS.sinter(followers_key, user.followers_key)
                               User.where(twitter_id: ids).order("badges_count DESC").limit(10)
                             end
  end

  def followed_repos(since=2.months.ago)
    REDIS.zrevrange(followed_repo_key, 0, since.to_i).collect { |link| FollowedRepo.new(link) }
  end

  def networks
    self.following_networks
  end

  def is_mayor_of?(network)
    network.mayor.try(:id) == self.id
  end

  def networks_based_on_skills
    self.skills.collect { |skill| Network.all_with_tag(skill.name) }.flatten.uniq
  end

  def visited!
    self.append_latest_visits(Time.now) if self.last_request_at && (self.last_request_at < 1.day.ago)
    self.touch(:last_request_at)
  end

  def latest_visits
    @latest_visits ||= self.visits.split(";").map(&:to_time)
  end

  def append_latest_visits(timestamp)
    self.visits = (self.visits.split(";") << timestamp.to_s).join(";")
    self.visits.slice!(0, self.visits.index(';')+1) if self.visits.length >= 64
    calculate_frequency_of_visits!
  end

  def average_time_between_visits
    @average_time_between_visits ||= (self.latest_visits.each_with_index.map { |visit, index| visit - self.latest_visits[index-1] }.reject { |difference| difference < 0 }.reduce(:+) || 0)/self.latest_visits.count
  end

  def calculate_frequency_of_visits!
    self.visit_frequency = begin
                             if average_time_between_visits < 2.days
                               :daily
                             elsif average_time_between_visits < 10.days
                               :weekly
                             elsif average_time_between_visits < 40.days
                               :monthly
                             else
                               :rarely
                             end
                           end
  end

  class FollowedRepo
    attr_reader :data

    def initialize(data)
      @data = JSON.parse(data)
    end

    def description
      data['description']
    end

    def repo
      data['link'].gsub('https://github.com/', '')
    end

    def date
      @date ||= Date.parse(data['date'])
    end

    def link
      data['link']
    end

    def user
      User.find(data['user_id'])
    end
  end

  def followed_repo_key
    "user:#{id}:following:repos"
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

  def subscribed_to_topic?(topic)
    tag = Tag.from_topic(topic).first
    tag && following?(tag)
  end

  def subscribe_to(topic)
    tag = Tag.from_topic(topic).first
    tag.subscribe(self) unless tag.nil?
  end

  def unsubscribe_from(topic)
    tag = Tag.from_topic(topic).first
    tag.unsubscribe(self) unless tag.nil?
  end

  def protip_subscriptions
    following_tags
  end

  def bookmarked_protips(count=Protip::PAGESIZE, force=false)
    if force
      self.likes.where(likable_type: 'Protip').map(&:likable)
    else
      Protip.search("bookmark:#{self.username}", [], per_page: count)
    end
  end

  def authored_protips(count=Protip::PAGESIZE, force=false)
    if force
      self.protips
    else
      Protip.search("author:#{self.username}", [], per_page: count)
    end
  end

  def protip_subscriptions_for(topic, count=Protip::PAGESIZE, force=false)
    if force
      following?(tag) && Protip.for_topic(topic)
    else
      Protip.search_trending_by_topic_tags(nil, topic.to_a, 1, count)
    end
  end

  def api_key
    read_attribute(:api_key) || generate_api_key!
  end

  def generate_api_key!
    begin
      key = SecureRandom.hex(8)
    end while User.where(api_key: key).exists?
    update_attribute(:api_key, key)
    key
  end

  def join(network)
    self.follow(network)
  end

  def leave(network)
    self.stop_following(network)
  end

  def apply_to(job)
    job.apply_for(self)
  end

  def already_applied_for?(job)
    job.seized_by?(self)
  end

  def seen(feature_name)
    REDIS.SADD("user:seen:#{feature_name}", self.id.to_s)
  end

  def self.that_have_seen(feature_name)
    REDIS.SCARD("user:seen:#{feature_name}")
  end

  def seen?(feature_name)
    REDIS.SISMEMBER("user:seen:#{feature_name}", self.id.to_s) == 1 #true
  end

  def has_resume?
    !self.resume.blank?
  end

  private

  def load_github_profile
    self.github.blank? ? nil : (cached_profile || fresh_profile)
  end

  def cached_profile
    self.github_id.present? && GithubProfile.where(github_id: self.github_id).first
  end

  def fresh_profile
    GithubProfile.for_username(self.github).tap do |profile|
      self.update_attribute(:github_id, profile.github_id)
    end
  end

  before_save :destroy_badges

  def destroy_badges
    unless @badges_to_destroy.nil?
      self.badges.where(badge_class_name: @badges_to_destroy).destroy_all
      @badges_to_destroy = nil
    end
  end

  before_create :make_referral_token

  def make_referral_token
    if self.referral_token.nil?
      self.referral_token = SecureRandom.hex(8)
    end
  end

  after_save :refresh_dependencies
  after_destroy :refresh_protips

  def refresh_dependencies
    if username_changed? or avatar_changed? or team_document_id_changed?
      refresh_protips
    end
  end

  def refresh_protips
    self.protips.each do |protip|
      protip.index_search
    end
    return true
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
#  beta_access                   :boolean          default(FALSE)
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
