# encoding utf-8
require 'search'

#Rename to Team when Mongodb is dropped
class Team < ActiveRecord::Base
  DEFAULT_HEX_BRAND        = '#343131'
  LEADERBOARD_KEY          = 'teams:leaderboard'
  FEATURED_TEAMS_CACHE_KEY = 'featured_teams_results'
  MAX_TEAM_SCORE           = 400

  self.table_name = 'teams'

  include SearchModule
  include TeamSearch
  include LeaderboardRedisRank
  include TeamAnalytics
  include TeamMigration

  mount_uploader :avatar, TeamUploader

  mapping team: {
    properties: {
      id:                 { type: 'string', index: 'not_analyzed' },
      slug:               { type: 'string', index: 'not_analyzed' },
      name:               { type: 'string', boost: 100, analyzer: 'snowball' },
      score:              { type: 'float', index: 'not_analyzed' },
      size:               { type: 'integer', index: 'not_analyzed' },
      avatar:             { type: 'string', index: 'not_analyzed' },
      country:            { type: 'string', boost: 50, analyzer: 'snowball' },
      url:                { type: 'string', index: 'not_analyzed' },
      follow_path:        { type: 'string', index: 'not_analyzed' },
      hiring:             { type: 'boolean', index: 'not_analyzed' },
      total_member_count: { type: 'integer', index: 'not_analyzed' },
      completed_sections: { type: 'integer', index: 'not_analyzed' },
      team_members:       { type: 'multi_field', fields: {
        username:    { type: 'string', index: 'not_analyzed' },
        profile_url: { type: 'string', index: 'not_analyzed' },
        avatar:      { type: 'string', index: 'not_analyzed' }
      } }
    }
  }

  scope :featured, ->{ where(premium: true, valid_jobs: true, hide_from_featured: false) }


  before_validation :create_slug!

  validates :slug, uniqueness: true, presence: true


  has_many :followers, through: :follows, source: :team

  has_many :follows,   class_name: 'FollowedTeam',    foreign_key: 'team_id', dependent: :destroy
  has_many :jobs,      class_name: 'Opportunity',     foreign_key: 'team_id', dependent: :destroy
  has_many :links,     class_name: 'Teams::Link',     foreign_key: 'team_id', dependent: :delete_all
  has_many :locations, class_name: 'Teams::Location', foreign_key: 'team_id', dependent: :delete_all
  has_many :members,   class_name: 'Teams::Member',   foreign_key: 'team_id', dependent: :delete_all
  has_one :account,    class_name: 'Teams::Account',  foreign_key: 'team_id', dependent: :delete

  def featured_links
    links
  end

  has_many :jobs, class_name: 'Opportunity', foreign_key: 'team_id', dependent: :destroy

  private def create_slug!
    self.slug = name.parameterize
  end

  def all_jobs
    jobs.order('created_at DESC')
  end

  has_many :follows, class_name: 'FollowedTeam', foreign_key: 'team_id', dependent: :destroy
  has_many :followers, through: :follows, source: :team

  accepts_nested_attributes_for :locations, :links, allow_destroy: true, reject_if: :all_blank

  scope :featured, ->{ where(premium: true, valid_jobs: true, hide_from_featured: false) }

  mount_uploader :avatar, TeamUploader

  before_validation :create_slug!

  validates :slug, uniqueness: true, presence: true
  validates :name, presence: true

  private def create_slug!
    self.slug = name.parameterize
  end

  before_save :update_team_size!
  before_save :clear_cache_if_premium_team
  before_validation :fix_website_url!
  after_create :generate_event
  after_save :reindex_search
  after_destroy :reindex_search
  after_destroy :remove_dependencies

  scope :featured, ->{ where(premium: true, valid_jobs: true, hide_from_featured: false) }

  def self.search(query_string, country, page, per_page, search_type = :query_and_fetch)
    country = query_string.gsub!(/country:(.+)/, '') && $1 if country.nil?
    query = ''

    if query_string.blank? or query_string =~ /:/
      query += query_string
    else
      query += "name:#{query_string}*"
    end

    begin
      tire.search(load: false, search_type: search_type, page: page, per_page: per_page) do
        query { string query, default_operator: 'AND' } if query_string.present?
        filter :term, country: country unless country.nil?
        sort { by [{ score: 'desc', total_member_count: 'desc', '_score' => {} }] }
      end
    rescue Tire::Search::SearchRequestFailed => e
      SearchResultsWrapper.new(nil, "Looks like our teams server is down. Try again soon.")
    end
  end

  def self.slugify(name)
    if !!(name =~ /\p{Latin}/)
      name.to_s.downcase.gsub(/[^a-z0-9]+/i, '-').chomp('-')
    else
      name.to_s.gsub(/\s/, "-")
    end
  end

  def self.most_relevant_featured_for(user)
    Team.featured.sort_by { |team| -team.match_score_for(user) }
  end

  def self.completed_at_least(section_count = 6, page=1, per_page=Team.count, search_type = :query_and_fetch)
    Team.search("completed_sections:[ #{section_count} TO * ]", nil, page, per_page, search_type)
  end

  def self.with_similar_names(name)
    name.gsub!(/ \-\./, '.*')
    teams = Team.any_of({ :name => /#{name}.*/i }).limit(3).to_a
  end

  def self.with_completed_section(section)
    empty = Team.new.send(section).is_a?(Array) ? [] : nil
    Team.where(section.to_sym.ne => empty)
  end

  def relevancy
    Protip.search_trending_by_team(slug, "created_at:[#{1.week.ago.strftime('%Y-%m-%dT%H:%M:%S')} TO *]", 1, 100).count
  end

  def match_score_for(user)
    team_skills = self.tokenized_stack.blank? ? self.tokenized_job_tags : self.tokenized_stack
    (user.skills.map(&:tokenized) & team_skills).count
  end

  def best_positions_for(user)
    user_skills = user.skills.map(&:tokenized)
    self.jobs.sort_by { |job| -(job.tags.map { |tag| Skill.tokenize(tag) } & user_skills).count }
  end

  def most_influential_members_for(user)
    influencers = user.following_by_type(User.name).where('follows.followable_id in (?)', self.team_members.map(&:id))
    (influencers + self.team_members.first(3)).uniq
  end

  def hiring_message
    (!self.hiring_tagline.blank? && self.hiring_tagline) || (!self.about.blank? && self.about) || (!self.big_quote.blank? && self.big_quote)
  end

  def tokenized_stack
    @tokenized_stack ||= self.stack.collect { |stack| Skill.tokenize(stack) }
  end

  def tokenized_job_tags
    @tokenized_job_tags ||= self.jobs.map(&:tags).flatten.collect { |tag| Skill.tokenize(tag) }
  end

  def tags_for_jobs
    (self.stack + self.jobs.map(&:tags).flatten)
  end

  def has_protips?
    trending_protips.size > 0
  end

  def trending_protips(limit=4)
    Protip.search_trending_by_team(slug, nil, 1, limit)
  end

  def company?
    true
  end

  def university?
    true
  end

  def locations_message
    if premium?
      locations.collect(&:name).join(', ')
    else
      locations.join(', ')
    end
  end

  def dominant_country_of_members
    members.select([:country, 'count(country) as count']).group([:country]).order('count DESC').limit(1).map(&:country)
  end

  def team_members
    members
  end

  def reach
    team_member_ids = team_members.map(&:id)
    Follow.where(followable_type: 'User', followable_id: team_member_ids).count + Follow.where(follower_id: team_member_ids, follower_type: 'User').count
  end

  def on_team?(user)
    has_member?(user)
  end

  def has_member?(user)
    team_members.include?(user)
  end


  def branding_hex_color
    branding || DEFAULT_HEX_BRAND
  end

  def events
    @events ||= team_members.collect { |user| user.followed_repos }.flatten.sort { |x, y| y.date <=> x.date }
  end

  def achievements_with_counts
    @achievements_with_counts ||= begin
                                    achievements = {}
                                    team_members.each do |user|
                                      user.badges.each do |badge|
                                        achievements[badge.badge_class] = 0 if achievements[badge.badge_class].blank?
                                        achievements[badge.badge_class] += 1
                                      end
                                    end
                                    achievements.sort_by { |k, v| v }.reverse
                                  end
  end

  def top_team_members
    top_three_team_members.map do |member|
      {
        username:    member.username,
        profile_url: member.profile_url,
        avatar:      ApplicationController.helpers.users_image_path(member)
      }
    end
  end

  def to_indexed_json
    summary.merge(
      score:              score.to_i,
      type:               self.class.name.downcase,
      url:                Rails.application.routes.url_helpers.team_path(self),
      follow_path:        Rails.application.routes.url_helpers.follow_team_path(self),
      team_members:       top_team_members,
      total_member_count: total_member_count,
      completed_sections: number_of_completed_sections,
      country:            dominant_country_of_members,
      hiring:             hiring?,
      locations:          locations_message.split(",").map(&:strip)
    ).to_json
  end

  def public_json
    public_hash.to_json
  end

  def public_hash
    neighbors = Team.find((higher_competitors(5) + lower_competitors(5)).flatten.uniq)
    summary.merge(
      neighbors:    neighbors.collect(&:summary),
      team_members: team_members.collect { |user| {
        name:               user.display_name,
        username:           user.username,
        badges_count:       user.badges_count,
        endorsements_count: user.endorsements_count
      } }
    )
  end

  def summary
    {
      name:   name,
      about:  about,
      id:     id.to_s,
      rank:   rank,
      size:   size,
      slug:   slug,
      avatar: avatar_url,
    }
  end

  def ranked?
    total_member_count >= 3 && rank != 0
  end

  def display_name
    name
  end

  def hiring?
    premium? && valid_jobs? && jobs.any?
  end

  alias_method :hiring, :hiring?

  def can_upgrade?
    !premium? && !valid_jobs?
  end

  def has_big_headline?
    !headline.blank?
  end

  def has_big_quote?
    !big_quote.blank? || !youtube_url.blank?
  end

  def has_challenges?
    !our_challenge.blank?
  end

  def has_favourite_benefits?
    !benefit_description_1.blank?
  end

  def has_organization_style?
    !organization_way.blank?
  end

  def has_office_images?
    !office_photos.blank?
  end

  def has_open_positions?
    !jobs.blank? && hiring?
  end

  def has_stack?
    !stack.blank?
  end

  def has_why_work?
    !reason_name_1.blank?
  end

  def has_interview_steps?
    !interview_steps.blank? && !interview_steps.first.blank?
  end

  def has_locations?
    !locations.blank?
  end

  def has_featured_links?
    !featured_links.blank?
  end

  def has_upcoming_events?
    false
  end

  def has_team_blog?
    !blog_feed.blank?
  end

  def has_achievements?
    !achievements_with_counts.empty?
  end

  def has_specialties?
    !specialties_with_counts.empty?
  end

  def specialties_with_counts
    @specialties_with_counts ||= begin
                                   specialties = {}
                                   team_members.each do |user|
                                     user.speciality_tags.each do |tag|
                                       tag              = tag.downcase
                                       specialties[tag] = 0 if specialties[tag].blank?
                                       specialties[tag] += 1
                                     end
                                   end
                                   unless only_one_occurence_of_each = specialties.values.sum == specialties.values.length
                                     specialties.reject! { |k, v| v <= 1 }
                                   end
                                   specialties.sort_by { |k, v| v }.reverse[0..7]
                                 end
  end

  def empty?
    (team_members.size) <= 0
  end

  def pending_size
    team_members.size + invited_emails.size
  end

  def is_invited?(user)
    !pending_team_members.where(user_id: id_of(user)).first.nil?
  end

  def is_member?(user)
    team_members.include?(user)
  end

  def membership(user)
    team_members.where(user_id: id_of(user)).first
  end

  #migrated
  # .members.top
  def top_team_member
    sorted_team_members.first
  end

  #migrated
  # .members.top(2)
  def top_two_team_members
    sorted_team_members[0...2] || []
  end


  #migrated
  # .members.top(3)
  def top_three_team_members
    sorted_team_members[0...3] || []
  end

  #migrated
  # .members.sorted
  def sorted_team_members
    @sorted_team_members = members.order('score_cache DESC')
  end


  def add_user(user)
    touch!
    user.tap do |u|
      u.update_attribute(:team_document_id, id.to_s)
      u.save!
    end
  end

  def add_member(user)
    Rails.logger.warn("Called #{self.class.name}#add_member(#{user.inspect}")
    require 'pry'; binding.pry unless Rails.env.production?

    return member if member = members.select { |m| m.user_id == user.id }
    member = members.create(user_id: user.id)
    save!
    member
  end

  def remove_member(user)
    require 'pry'; binding.pry

    return nil unless member = members.select { |m| m.user_id == user.id }
    members.destroy(member)
    save!
  end

  def touch!
    self.updated_at = Time.now.utc
    save!(validate: !skip_validations)
  end

  def total_member_count
    members.count
  end

  def total_highlights_count
    team_members.collect { |u| u.highlights.count }.sum
  end

  def team_size_threshold
    if size >= 3
      3
    else
      size
    end
  end

  def <=> y
    val = team_size_threshold <=> y.team_size_threshold
    return val unless val == 0

    val = score <=> y.score
    return val unless val == 0

    val = size <=> y.size
    return val unless val == 0

    val = total_highlights_count <=> y.total_highlights_count
    return val unless val == 0

    id.to_s <=> y.id.to_s
  end

  def recalculate!
    return nil if team_members.size <= 0
    log_history!
    update_team_size!
    self.total             = team_members.collect(&:score).sum
    self.achievement_count = team_members.collect { |t| t.badges.count }.sum
    self.endorsement_count = team_members.collect { |t| t.endorsements.count }.sum
    self.mean              = team_members.empty? ? 0 : (total / team_members_with_scores.size).to_f
    self.median            = calculate_median
    self.score             = [real_score, MAX_TEAM_SCORE].min
    save!
  end

  def real_score
    ((median + mean) * multipler) + size_credit + members_with_score_above(mean) + leader_score + 100
  end

  def leader_score
    [leader.score, 50].min
  end

  def leader
    sorted_team_members.sort { |x, y| x.score <=> y.score }.reverse.first
  end

  def multipler
    team_score = team_members_with_scores.size
    if  team_score <= 3
      0.50
    elsif team_score <= 4
      0.75
    elsif team_score <= 5
      0.90
    else
      Math.log(team_members_with_scores.size - 2, 3)
    end
    # team_size = team_members_with_scores.size
    # if team_size <= 4
    #   0.95
    # else
    #   1
    # end
  end

  def members_with_score_above(score)
    team_members.select { |u| u.score >= score }.size
  end

  def size_credit
    if size < 20
      size / 2
    else
      20 / 2
    end
  end

  def calculate_median
    sorted = team_members.collect(&:score).sort
    return 0 if sorted.empty?
    lower = sorted[(sorted.size/2) - 1]
    upper = sorted[((sorted.size+1)/2) -1]
    (lower + upper) / 2
  end

  def team_members_with_scores
    @team_members_with_scores ||= team_members.collect { |t| t.score > 0 }
  end

  def log_history!
    Redis.current.rpush("team:#{id.to_s}:score", {
      date:  Date.today,
        score: self.score,
        size:  self.size
    }.to_json)
  end

  def predominant
    skill = {}
    team_members.each do |member|
      member.user.repositories.each do |repo|
        repo.tags.each do |tag|
          skill[tag] = (skill[tag] ||= 0) + 1
        end
      end
    end
    skill
  end

  def admin?(user)
    return false if user.nil?
    return true if user.admin?
    if everyone_is_an_admin = admins.empty?
      team_members.include?(user)
    else
      admins.include?(user.id)
    end
  end

  def timeline_key
    @timeline_key ||= "team:#{id.to_s}:timeline"
  end

  def has_user_with_referral_token?(token)
    team_members.collect(&:referral_token).include?(token)
  end

  def impressions_key
    "team:#{id}:impressions"
  end

  def user_views_key
    "team:#{id}:views"
  end

  def user_anon_views_key
    "team:#{id}:views:anon"
  end

  def user_detail_views_key
    "team:#{id}:views:detail"
  end

  def viewed_by(viewer)
    epoch_now = Time.now.to_i
    Redis.current.incr(impressions_key)
    if viewer.is_a?(User)
      Redis.current.zadd(user_views_key, epoch_now, viewer.id)
    else
      Redis.current.zadd(user_anon_views_key, epoch_now, viewer)
    end
  end

  def impressions
    Redis.current.get(impressions_key).to_i
  end

  def viewers(since=0)
    epoch_now  = Time.now.to_i
    viewer_ids = Redis.current.zrevrangebyscore(user_views_key, epoch_now, since)
    User.where(id: viewer_ids).all
  end

  def total_views(epoch_since = 0)
    epoch_now = Time.now.to_i
    Redis.current.zcount(user_views_key, epoch_since, epoch_now) + Redis.current.zcount(user_anon_views_key, epoch_since, epoch_now)
  end

  def self.most_active_countries
    Country.where(name: User.select([:country, 'count(country) as count']).group(:country).order('count DESC').limit(10).map(&:country)).reverse
  end

  def primary_address
    locations.first.try(:address) || primary_address_name
  end

  def primary_address_name
    locations.first.try(:name)
  end

  def primary_address_description
    locations.first.try(:description)
  end

  def primary_points_of_interest
    locations.first.try(:points_of_interest).to_a
  end

  def cities
    locations.map(&:city).reject { |city| city.blank? }
  end

  def generate_event
    only_member_is_creator = team_members.first.try(:id)
    GenerateEventJob.perform_async(self.event_type, Audience.following_user(only_member_is_creator), self.to_event_hash, 1.minute) unless only_member_is_creator.nil?
  end

  def to_event_hash
    { user: { username: team_members.any? && team_members.first.username } }
  end

  def event_type
    :new_team
  end

  def fix_website_url!
    unless self.website.blank? or self.website =~ /^https?:\/\//
      self.website = "http://#{self.website}"
    end
  end

  def active_jobs
    jobs[0...4]
  end

  def active_job_titles
    active_jobs.collect(&:title).uniq
  end




  SECTION_FIELDS = %w(about headline big_quote our_challenge benefit_description_1 organization_way office_photos stack_list reason_name_1 interview_steps locations blog_feed)


  def visitors_interested_in_jobs
    aggregate_visitors.select { |visitor| visitor[:exit_target_type] == 'job-opportunity' }.collect { |visitor| visitor[:user_id] }
  end

  def members_interested_in_jobs
    User.where(id: aggregate_visitors.select { |visitor| visitor[:exit_target_type] == 'job-opportunity' || visitor[:exit_target_type] == 'all-job-opportunities' }.collect { |visitor| visitor[:user_id] }).compact
  end

  def click_through_rate
    self.visitors_interested_in_jobs.count/self.total_views(self.upgraded_at)
  end

  def coderwall?
    slug == 'coderwall'
  end

  def reindex_search
    if Rails.env.development? or Rails.env.test? or self.destroyed?
      self.tire.update_index
    else
      IndexTeamJob.perform_async(id)
    end
  end

  def remove_dependencies
    [FollowedTeam, Invitation, Opportunity, SeizedOpportunity].each do |klass|
      klass.where(team_id: self.id.to_s).delete_all
    end
    User.where(team_id: self.id.to_s).update_all('team_id = NULL')
  end

  def rerank!
    ProcessTeamJob.perform_async('recalculate', id)
  end

  def can_post_job?
    has_monthly_subscription? || paid_job_posts > 0
  end

  def has_monthly_subscription?
    self.monthly_subscription
  end

  def has_specified_enough_info?
    number_of_completed_sections >= 6
  end

  def has_team_details?
    has_external_link? and !self.about.nil? and !self.avatar.nil?
  end

  def has_external_link?
    self.twitter.nil? or self.facebook.nil? or self.website.nil? or self.github.nil?
  end

  def has_members?
    team_members.count >= 2
  end

  def stack
    @stack_list ||= (self.stack_list || "").split(/,/)
  end

  def blog
    unless self.blog_feed.blank?
      feed = Feedjira::Feed.fetch_and_parse(self.blog_feed)
      feed unless feed.is_a?(Fixnum)
    end
  end

  def blog_posts
    @blog_posts ||= blog.try(:entries) || []
  end

  def plan
    plan_id = self.account && self.account.plan_ids.first
    plan_id && Plan.find(plan_id)
  end

  def plan=(plan)
    self.build_account
    self.account.admin_id = self.admins.first || self.team_members.first.id
    self.account.subscribe_to!(plan, true)
  end

  def edited_by(user)
    self.editors.delete(user.id)
    self.editors << user.id
  end

  def latest_editors
    self.editors.collect { |editor| User.where(id: editor).first }.compact
  end

  def video_url
    if self.youtube_url =~ /vimeo\.com\/(\d+)/
      "https://player.vimeo.com/video/#{$1}"
    elsif self.youtube_url =~ /(youtube\.com|youtu\.be)\/(watch\?v=)?([\w\-_]{11})/i
      "https://www.youtube.com/embed/#{$3}"
    else
      self.youtube_url
    end
  end

  def request_to_join(user)
    self.pending_join_requests << user.id
  end

  def approve_join_request(user)
    self.add_member(user)
    self.pending_join_requests.delete user.id
  end

  def deny_join_request(user)
    self.pending_join_requests.delete user.id
  end

  private

  def identify_visitor(visitor_name)
    visitor_id = visitor_name.to_i
    if visitor_id != 0 and visitor_name =~ /^[0-9]+$/i
      User.where(id: visitor_id).first
    else
      nil
    end
  end

  def visitor_data(exit_url, exit_target_type, furthest_scrolled, time_spent, user_id, visited_at, user)
    { exit_url:          exit_url,
      exit_target_type:  exit_target_type,
      furthest_scrolled: furthest_scrolled,
      time_spent:        time_spent,
      user_id:           user_id,
      visited_at:        visited_at,
      user:              user }
  end

  def id_of(user)
    user.is_a?(User) ? user.id : user
  end

  #Replaced with team_size attribute
  def update_team_size!
    self.size = User.where(team_id: self.id.to_s).count
  end

  def clear_cache_if_premium_team
    Rails.cache.delete(Team::FEATURED_TEAMS_CACHE_KEY) if premium?
  end

  def create_slug!
    self.slug = self.class.slugify(name)
  end
end
#

# == Schema Information
#
# Table name: teams
#
#  id                       :integer          not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  website                  :string(255)
#  about                    :text
#  total                    :decimal(40, 30)  default(0.0)
#  size                     :integer          default(0)
#  mean                     :decimal(40, 30)  default(0.0)
#  median                   :decimal(40, 30)  default(0.0)
#  score                    :decimal(40, 30)  default(0.0)
#  twitter                  :string(255)
#  facebook                 :string(255)
#  slug                     :string(255)
#  premium                  :boolean          default(FALSE)
#  analytics                :boolean          default(FALSE)
#  valid_jobs               :boolean          default(FALSE)
#  hide_from_featured       :boolean          default(FALSE)
#  preview_code             :string(255)
#  youtube_url              :string(255)
#  github                   :string(255)
#  highlight_tags           :string(255)
#  branding                 :text
#  headline                 :text
#  big_quote                :text
#  big_image                :string(255)
#  featured_banner_image    :string(255)
#  benefit_name_1           :text
#  benefit_description_1    :text
#  benefit_name_2           :text
#  benefit_description_2    :text
#  benefit_name_3           :text
#  benefit_description_3    :text
#  reason_name_1            :text
#  reason_description_1     :text
#  reason_name_2            :text
#  reason_description_2     :text
#  reason_name_3            :text
#  reason_description_3     :text
#  why_work_image           :text
#  organization_way         :text
#  organization_way_name    :text
#  organization_way_photo   :text
#  featured_links_title     :string(255)
#  blog_feed                :text
#  our_challenge            :text
#  your_impact              :text
#  hiring_tagline           :text
#  link_to_careers_page     :text
#  avatar                   :string(255)
#  achievement_count        :integer          default(0)
#  endorsement_count        :integer          default(0)
#  upgraded_at              :datetime
#  paid_job_posts           :integer          default(0)
#  monthly_subscription     :boolean          default(FALSE)
#  stack_list               :text             default("")
#  number_of_jobs_to_show   :integer          default(2)
#  location                 :string(255)
#  country_id               :integer
#  name                     :string(255)
#  github_organization_name :string(255)
#  team_size                :integer
#  mongo_id                 :string(255)
#  office_photos            :string(255)      default([]), is an Array
#  upcoming_events          :text             default([]), is an Array
#  interview_steps          :text             default([]), is an Array
#  invited_emails           :string(255)      default([]), is an Array
#  pending_join_requests    :string(255)      default([]), is an Array
#  state                    :string(255)      default("active")
#
