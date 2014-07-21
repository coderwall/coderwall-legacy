# encoding: utf-8
# Postgresed  [WIP] : Pg_Team
require 'search'

class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include LeaderboardRedisRank
  include SearchModule

  # Disabled Team indexing because it slows down updates
  # we should BG this
  #include Tire::Model::Callbacks

  include TeamMapping

  DEFAULT_HEX_BRAND        = '#343131'
  LEADERBOARD_KEY          = 'teams:leaderboard'
  FEATURED_TEAMS_CACHE_KEY = 'featured_teams_results'
  MAX_TEAM_SCORE           = 400

  field :name
  field :website
  field :location
  field :about
  field :total, default: 0
  field :size, default: 0
  field :mean, default: 0
  field :median, default: 0
  field :score, default: 0
  field :twitter
  field :facebook
  field :slug
  field :premium, default: false, type: Boolean
  field :analytics, default: false, type: Boolean
  field :valid_jobs, default: false, type: Boolean
  field :hide_from_featured, default: false, type: Boolean
  field :preview_code
  field :youtube_url

  field :github_organization_name
  alias :github :github_organization_name

  field :highlight_tags
  field :branding
  field :headline
  field :big_quote
  field :big_image
  field :featured_banner_image

  field :benefit_name_1
  field :benefit_description_1
  field :benefit_name_2
  field :benefit_description_2
  field :benefit_name_3
  field :benefit_description_3

  field :reason_name_1
  field :reason_description_1
  field :reason_name_2
  field :reason_description_2
  field :reason_name_3
  field :reason_description_3
  field :why_work_image

  field :organization_way
  field :organization_way_name
  field :organization_way_photo

  field :office_photos, type: Array, default: []
  field :upcoming_events, type: Array, default: [] #just stubbed

  field :featured_links_title
  embeds_many :featured_links, class_name: TeamLink.name

  field :blog_feed
  field :our_challenge
  field :your_impact

  field :interview_steps, type: Array, default: []
  field :hiring_tagline
  field :link_to_careers_page

  field :avatar
  mount_uploader :avatar, AvatarUploader

  field :achievement_count, default: 0
  field :endorsement_count, default: 0
  field :invited_emails, type: Array, default: []
  field :country_id

  field :admins, type: Array, default: []
  field :editors, type: Array, default: []

  field :pending_join_requests, type: Array, default: []

  embeds_one :account
  field :upgraded_at
  field :paid_job_posts, default: 0
  field :monthly_subscription, default: false
  field :stack_list, default: nil
  field :number_of_jobs_to_show, default: 2

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :slug

  index({ name: 1 }, { unique: true })
  index({ slug: 1 }, { unique: true })

  embeds_many :pending_team_members, class_name: 'TeamMember'

  embeds_many :team_locations

  accepts_nested_attributes_for :team_locations, :featured_links, allow_destroy: true, reject_if: :all_blank

  before_save :update_team_size!
  before_save :clear_cache_if_premium_team
  before_validation :create_slug!
  before_validation :fix_website_url!
  attr_accessor :skip_validations
  after_create :generate_event
  after_save :reindex_search
  after_destroy :reindex_search
  after_destroy :remove_dependencies

  scope :featured, ->{ where(premium: true, valid_jobs: true, hide_from_featured: false) }

  if Rails.env.development? #for Oli
    def avatar_url
      url = super
      url = 'team-avatar.png'
      if url.include?('http')
        'team-avatar.png'
      else
        url
      end
    end
  end

  class << self

    def with_name(name)
      where(name: name).first
    end

    def search(query_string, country, page, per_page, search_type = :query_and_fetch)
      country = query_string.gsub!(/country:(.+)/, '') && $1 if country.nil?
      query   = ""
      if query_string.blank? or query_string =~ /:/
        query += query_string
      else
        query += "name:#{query_string}*"
      end
      #query += "country:#{country}" unless country.nil?
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

    def slugify(name)
      if !!(name =~ /\p{Latin}/)
        name.to_s.downcase.gsub(/[^a-z0-9]+/i, '-').chomp('-')
      else
        name.to_s.gsub(/\s/, "-")
      end
    end

    def has_jobs
      Team.find(Opportunity.valid.select(:team_document_id).map(&:team_document_id))
    end

    def most_relevant_featured_for(user)
      Team.featured.sort_by { |team| -team.match_score_for(user) }
    end

    def completed_at_least(section_count = 6, page=1, per_page=Team.count, search_type = :query_and_fetch)
      Team.search("completed_sections:[ #{section_count} TO * ]", nil, page, per_page, search_type)
    end

    def with_completed_section(section)
      empty = Team.new.send(section).is_a?(Array) ? [] : nil
      Team.where(section.to_sym.ne => empty)
    end
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

  def company?
    true
  end

  def university?
    true
  end

  def trending_protips(limit=4)
    Protip.search_trending_by_team(self.slug, nil, 1, limit)
  end

  def locations
    (location || '').split(';').collect { |location| location.strip }
  end

  def locations_message
    if premium?
      team_locations.collect(&:name).join(', ')
    else
      locations.join(', ')
    end
  end

  def dominant_country_of_members
    User.where(team_document_id: self.id.to_s).select([:country, 'count(country) as count']).group([:country]).order('count DESC').limit(1).map(&:country)
  end

  def team_members
    @team_members ||= User.where(team_document_id: self.id.to_s).all
  end

  def reload_team_members
    @team_members = nil
  end

  def reach
    team_member_ids = team_members.map(&:id)
    Follow.where(followable_type: 'User', followable_id: team_member_ids).count + Follow.where(follower_id: team_member_ids, follower_type: 'User').count
    #team_members.collect{|member| member.followers.count + member.following.count }.sum
  end

  def has_member?(user)
    team_members.include?(user)
  end

  def on_team?(user)
    has_member?(user)
  end

  def branding_hex_color
    branding || DEFAULT_HEX_BRAND
  end

  def collective_days_on_github
    @collective_days_on_github ||= begin
                                     days = team_members.collect { |user| days_since(user.joined_github_on) }.sum
                                     # [(days / 365), (days % 365)]
                                   end
  end

  def collective_days_on_twitter
    @collective_days_on_twitter ||= begin
                                      days = team_members.collect { |user| days_since(user.joined_twitter_on) }.sum
                                      # [(days / 365), (days % 365)]
                                      # / ==#{@team.collective_days_on_twitter.first} yrs & #{@team.collective_days_on_twitter.last} days
                                    end
  end

  def days_since(date)
    return 0 if date.nil?
    ((Time.now - date.to_time).abs / 60 / 60 / 24).round
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
    !team_locations.blank?
  end

  def has_featured_links?
    !featured_links.blank?
  end

  def has_upcoming_events?
    !upcoming_events.blank?
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

  def top_team_member
    sorted_team_members.first
  end

  def top_two_team_members
    sorted_team_members[0...2] || []
  end

  def top_three_team_members
    sorted_team_members[0...3] || []
  end

  def sorted_team_members
    @sorted_team_members = User.where(team_document_id: self.id.to_s).order('score_cache DESC')
  end

  def add_user(user)
    user.update_attribute(:team_document_id, id.to_s)
    touch!
    user.save!
    user
  end

  def remove_user(user)
    if user.team_document_id.to_s == self.id.to_s
      user.update_attribute(:team_document_id, nil)
      touch!
      self.destroy if self.reload.empty?
    end
  end

  def touch!
    self.updated_at = Time.now.utc
    save!(validate: !skip_validations)
  end

  def total_member_count
    User.where(team_document_id: self.id.to_s).count
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

  def followers
    FollowedTeam.where(team_document_id: self.id.to_s)
  end

  def self.most_active_countries
    Country.where(name: User.select([:country, 'count(country) as count']).group(:country).order('count DESC').limit(10).map(&:country)).reverse
  end

  def primary_address
    team_locations.first.try(:address) || primary_address_name
  end

  def primary_address_name
    team_locations.first.try(:name)
  end

  def primary_address_description
    team_locations.first.try(:description)
  end

  def primary_points_of_interest
    team_locations.first.try(:points_of_interest).to_a
  end

  def cities
    team_locations.map(&:city).reject { |city| city.blank? }
  end

  def generate_event
    only_member_is_creator = team_members.first.try(:id)
    enqueue(GenerateEvent, self.event_type, Audience.following_user(only_member_is_creator), self.to_event_hash, 1.minute) unless only_member_is_creator.nil?
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

  #Will delete , it not even working
  def upcoming_events
    team_members.collect do |member|

    end
  end

  def active_jobs
    jobs[0...4]
  end

  def active_job_titles
    active_jobs.collect(&:title).uniq
  end

  def jobs
    all_jobs.valid
  end

  #Replaced with jobs
  def all_jobs
    Opportunity.where(team_document_id: self.id.to_s).order('created_at DESC')
  end

  def record_exit(viewer, exit_url, exit_target_type, furthest_scrolled, time_spent)
    epoch_now = Time.now.to_i
    data      = visitor_data(exit_url, exit_target_type, furthest_scrolled, time_spent, (viewer.respond_to?(:id) && viewer.try(:id)) || viewer, epoch_now, nil)
    Redis.current.zadd(user_detail_views_key, epoch_now, data)
  end

  def detailed_visitors(since = 0)
    Redis.current.zrangebyscore(user_detail_views_key, since, Time.now.to_i).map do |visitor_string|
      visitor = HashStringParser.better_than_eval(visitor_string)
      visitor[:user] = identify_visitor(visitor[:user_id])
      visitor
    end
  end

  def simple_visitors(since = 0)
    all_visitors = Redis.current.zrangebyscore(user_views_key, since, Time.now.to_i, withscores: true) + fRedis.current.zrangebyscore(user_anon_views_key, since, Time.now.to_i, withscores: true)
    Hash[*all_visitors.flatten].collect do |viewer_id, timestamp|
      visitor_data(nil, nil, nil, 0, viewer_id, timestamp, identify_visitor(viewer_id))
    end
  end

  def visitors(since=0)
    detailed_visitors    = self.detailed_visitors
    first_detailed_visit = detailed_visitors.last.nil? ? self.updated_at : detailed_visitors.first[:visited_at]
    self.detailed_visitors(since) + self.simple_visitors(since == 0 ? first_detailed_visit.to_i : since)
  end

  SECTIONS       = %w(team-details members about-members big-headline big-quote challenges favourite-benefits organization-style office-images jobs stack protips why-work interview-steps locations team-blog)
  SECTION_FIELDS = %w(about headline big_quote our_challenge benefit_description_1 organization_way office_photos stack_list reason_name_1 interview_steps team_locations blog_feed)

  def aggregate_visitors(since=0)
    aggregate ={}
    visitors(since).map do |visitor|
      user_id            = visitor[:user_id].to_i
      aggregate[user_id] ||= visitor
      aggregate[user_id].merge!(visitor) do |key, old, new|
        case key
        when :time_spent
          old.to_i + new.to_i
        when :visited_at
          [old.to_i, new.to_i].max
        when :furthest_scrolled
          SECTIONS[[SECTIONS.index(old) || 0, SECTIONS.index(new) || 0].max]
        else
          old.nil? ? new : old
        end
      end
      aggregate[user_id][:visits] ||= 0
      aggregate[user_id][:visits] += 1

    end
    aggregate.values.sort { |a, b| b[:visited_at] <=> a[:visited_at] }
  end

  def visitors_interested_in_jobs
    aggregate_visitors.select { |visitor| visitor[:exit_target_type] == 'job-opportunity' }.collect { |visitor| visitor[:user_id] }
  end

  def members_interested_in_jobs
    User.where(id: aggregate_visitors.select { |visitor| visitor[:exit_target_type] == 'job-opportunity' || visitor[:exit_target_type] == 'all-job-opportunities' }.collect { |visitor| visitor[:user_id] }).compact
  end

  def click_through_rate
    self.visitors_interested_in_jobs.count/self.total_views(self.upgraded_at)
  end

  def sections_up_to(furthest)
    SECTIONS.slice(0, SECTIONS.index(furthest))
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
      klass.where(team_document_id: self.id.to_s).delete_all
    end
    User.where(team_document_id: self.id.to_s).update_all('team_document_id = NULL')
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

  def number_of_completed_sections(*excluded_sections)
    completed_sections = 0

    (SECTIONS - excluded_sections).map { |section| "has_#{section.gsub(/-/, '_')}?" }.each do |section_complete|
      completed_sections +=1 if self.respond_to?(section_complete) && self.send(section_complete)
    end
    completed_sections
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
    self.add_user(user)
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
    self.size = User.where(team_document_id: self.id.to_s).count
  end

  def clear_cache_if_premium_team
    Rails.cache.delete(Team::FEATURED_TEAMS_CACHE_KEY) if premium?
  end

  def create_slug!
    self.slug = self.class.slugify(name)
  end

end
