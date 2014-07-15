require 'net_validators'
require 'open-uri'
require 'taggers'
require 'cfm'
require 'scoring'
require 'search'

class Protip < ActiveRecord::Base
  include Featurable
  # TODO: Break out the various responsibilities on the Protip into modules/concerns.

  include NetValidators
  include Tire::Model::Search
  include ResqueSupport::Basic
  include Scoring::HotStream
  include SearchModule
  include Rakismet::Model

  acts_as_commentable

  include ProtipMapping

  paginates_per(PAGESIZE = 18)

  URL_REGEX = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))/

  has_many :likes, as: :likable, dependent: :destroy, after_add: :reset_likes_cache, after_remove: :reset_likes_cache
  has_many :protip_links, autosave: true, dependent: :destroy, after_add: :reset_links_cache, after_remove: :reset_links_cache
  has_one :spam_report, as: :spammable
  belongs_to :user , autosave: true

  rakismet_attrs  author: proc { self.user.name },
    author_email: proc { self.user.email },
    content: :body,
    blog: ENV['AKISMET_URL'],
    user_ip: proc { self.user.last_ip },
    user_agent: proc { self.user.last_ua }

  attr_taggable :topics, :users
  attr_accessor :upvotes

  DEFAULT_IP_ADDRESS = '0.0.0.0'

  USER_SCOPE = ["!!mine", "!!bookmarks"]
  USER_SCOPE_REGEX = { author:   /!!m(ine)?/, bookmark: /!!b(ookmarks?)?/, }
  KINDS = [:link, :qa, :article]
  FEATURED_PHOTO = /\A\s*!\[[\w\s\W]*\]\(([\w\s\W]*)\)/i
  FORMATTERS = { q: /###[Qq|Pp]/, a: /###[Aa|Ss]/ }
  VALID_TAG = /[\w#\-\.\_\$\!\?\* ]+/

  #possible content creators
  IMPORTER = "coderwall:importer"
  SELF = "self"

  MAX_TITLE_LENGTH = 255

  #these settings affect the trending order
  COUNTABLE_VIEWS_CHUNK = 100.00
  UPVOTES_SCORE_BENCHMARK = 5112.0

  EPOCH = Time.at(1305712800)+10.years #begining of time according to protips. affects time score

  MIN_FLAG_THRESHOLD = 2

  before_validation :determine_kind
  before_validation :extract_data_from_links, unless: :invalid_links?
  before_validation :reformat_tags!
  before_validation :sanitize_tags!

  validates :title, presence: true, length: { minimum: 5, maximum: MAX_TITLE_LENGTH }
  validates :body, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :topics, length: { minimum: 1 }

  after_validation :tag_user
  before_create :assign_random_id
  before_save :process_links
  before_save :recalculate_score!

  # Begin these three lines fail the test
  after_save :index_search
  after_save :unqueue_flagged, if: :flagged?
  after_destroy :index_search_after_destroy
  after_create :update_network
  after_create :analyze_spam
  # End of test failing lines

  attr_accessor :upvotes_value


  scope :random, ->(count) { order("RANDOM()").limit(count) }
  scope :recent, ->(count) { order("created_at DESC").limit(count) }
  scope :for, ->(userlist) { where(user: userlist.map(&:id)) }
  scope :most_upvotes, ->(count) { joins(:likes).select(['protips.*', 'SUM(likes.value) AS like_score']).group(['likes.likable_id', 'protips.id']).order('like_score DESC').limit(count) }
  scope :any_topics, ->(topics_list) { where(id: select('DISTINCT protips.id').joins(taggings: :tag).where('tags.name IN (?)', topics_list)) }

  scope :topics, ->(topics_list, match_all) { match_all ? any_topics(topics_list).group('protips.id').having('count(protips.id)=?', topics_list.size) : any_topics(topics_list) }

  scope :for_topic, ->(topic) { any_topics([topic]) }

  scope :with_upvotes, joins("INNER JOIN (#{Like.select('likable_id, SUM(likes.value) as upvotes').where(likable_type: 'Protip').group([:likable_type, :likable_id]).to_sql}) AS upvote_scores ON upvote_scores.likable_id=protips.id")
  scope :trending, order('score DESC')
  scope :flagged, where(flagged: true)
  scope :queued_for, ->(queue) { ProcessingQueue.queue_for_type(queue, self.class.name) }

  class << self

    def most_upvotes_for_a_protip
      UPVOTES_SCORE_BENCHMARK
    end

    def override_score!(public_id, new_score)
      p = with_public_id(public_id)
      p.score = new_score
      p.save!
    end

    def trending_topics
      trending_protips = search(nil, [], page: 1, per_page: 100)

      unless trending_protips.respond_to?(:errored?) and trending_protips.errored?
        static_trending = ENV['FEATURED_TOPICS'].split(",").map(&:strip).map(&:downcase) unless ENV['FEATURED_TOPICS'].blank?
        dynamic_trending = trending_protips.map { |p| p.tags }.flatten.reduce(Hash.new(0)) { |h, tag| h.tap { |h| h[tag] += 1 } }.sort { |a1, a2| a2[1] <=> a1[1] }.map { |entry| entry[0] }.reject { |tag| User.where(username: tag).any? }
        ((static_trending || []) + dynamic_trending).uniq
      else
        Tag.last(20).map(&:name).reject { |name| User.exists?(username: name) }
      end
    end

    def with_public_id(public_id)
      where(public_id: public_id).first
    end

    def search_next(query, tag, index, page)
      return nil if page.nil? || (tag.blank? && query.blank?) #when your viewing a protip if we don't check this it thinks we came from trending and shows the next trending prootip eventhough we directly landed here
      page = (index.to_i * page.to_i) + 1
      tag = [tag] unless tag.is_a?(Array) || tag.nil?
      search(query, tag, page: page, per_page: 1).results.try(:first)
    end

    def search(query_string, tags =[], options={})
      query, team, author, bookmarked_by, execution, sorts= preprocess_query(query_string)
      tags = [] if tags.nil?
      tags = preprocess_tags(tags)
      tag_ids = process_tags_for_search(tags)
      tag_ids = [0] if !tags.blank? and tag_ids.blank?

      force_index_commit = Protip.tire.index.refresh if Rails.env.test?
      query_fields = [:title, :body]
      filters = []
      filters << {term: {upvoters: bookmarked_by}} unless bookmarked_by.nil?
      filters << {term: {'user.user_id' => author}} unless author.nil?
      Rails.logger.debug "SEARCH: query=#{query}, tags=#{tags}, team=#{team}, author=#{author}, bookmarked_by=#{bookmarked_by}, execution=#{execution}, sorts=#{sorts} from query-string=#{query_string}, #{options.inspect}"
      begin
        tire.search(options) do
          query { string query, default_operator: 'AND', use_dis_max: true } unless query.blank?
          filter :terms, tag_ids: tag_ids, execution: execution unless tag_ids.blank?
          filter :term, teams: team unless team.nil?
          if filters.size >= 2
            filter :or, *filters
          else
            filters.each do |fltr|
              filter *fltr.first
            end
          end
          sort { by [sorts] }
          #sort { by [{:upvotes => 'desc' }] }
        end
      rescue Tire::Search::SearchRequestFailed => e
        ::SearchResultsWrapper.new(nil, "Looks like our search servers are out to lunch. Try again soon.")
      end
    end

    def popular
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:popular_score),
                         nil,
                         nil).execute
    end

    def trending
      Protip::Search.new(Protip,
                         nil,
                         nil,
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def trending_for_user(user)
      Protip::Search.new(Protip,
                         nil,
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:trending_score),
                         nil,
                         nil).execute
    end

    def hawt_for_user(user)
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         Protip::Search::Scope.new(:user, user),
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def hawt
      Protip::Search.new(Protip,
                         Protip::Search::Query.new('best_stat.name:hawt'),
                         nil,
                         Protip::Search::Sort.new(:created_at),
                         nil,
                         nil).execute
    end

    def trending_by_topic_tags(tags)
      trending.topics(tags.split("/"), true)
    end

    def top_trending(page = 1, per_page = PAGESIZE)
      page = 1 if page.nil?
      per_page = PAGESIZE if per_page.nil?
      search_trending_by_topic_tags(nil, [], page, per_page)
    end

    def search_trending_by_team(team_id, query_string, page, per_page)
      options = { page: page, per_page: per_page }
      force_index_commit = Protip.tire.index.refresh if Rails.env.test?
      query = "team.name:#{team_id.to_s}"
      query              += " #{query_string}" unless query_string.nil?
      Protip.search(query, [], page: page, per_page: per_page)
    rescue Errno::ECONNREFUSED
      team = Team.where(slug: team_id).first
      team.team_members.collect(&:protips).flatten
    end

    def search_trending_by_user(username, query_string, tags, page, per_page)
      query = "author:#{username}"
      query += " #{query_string}" unless query_string.nil?
      Protip.search(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_topic_tags(query, tags, page, per_page)
      Protip.search(query, tags, page: page, per_page: per_page)
    end

    def search_trending_by_date(query, date, page, per_page)
      date_string = "#{date.midnight.strftime('%Y-%m-%dT%H:%M:%S')} TO #{(date.midnight + 1.day).strftime('%Y-%m-%dT%H:%M:%S')}" unless date.is_a?(String)
      query = "" if query.nil?
      query += " created_at:[#{date_string}]"
      Protip.search(query, [], page: page, per_page: per_page)
    end

    def search_bookmarked_protips(username, page, per_page)
      Protip.search("bookmark:#{username}", [], page: page, per_page: per_page)
    end

    def most_interesting_for(user, since=Time.at(0), page = 1, per_page = 10)
      search_top_trending_since("only_link:false", since, user.networks.map(&:ordered_tags).flatten.concat(user.skills.map(&:name)), page, per_page)
    end

    def search_top_trending_since(query, since, tags, page = 1, per_page = 10)
      query ||= ""
      query += " created_at:[#{since.strftime('%Y-%m-%dT%H:%M:%S')} TO *] sort:upvotes desc"
      search_trending_by_topic_tags(query, tags, page, per_page)
    end

    def preprocess_query(query_string)
      query = team = nil
      unless query_string.nil?
        query = query_string.dup
        query.gsub!(/(\d+)\"/, "\\1\\\"") #handle 27" cases
        team = query.gsub!(/(team:([0-9A-Z\-]+))/i, "") && $2
        team = (team =~ /^[a-f0-9]+$/i && team.length == 24 ? team : Team.where(slug: team).first.try(:id))
        author = query.gsub!(/author:([^\. ]+)/i, "") && $1.try(:downcase)
        author = User.with_username(author).try(:id) || 0 unless author.nil? or (author =~ /^\d+$/)
        bookmarked_by = query.gsub!(/bookmark:([^\. ]+)/i, "") && $1
        bookmarked_by = User.with_username(bookmarked_by).try(:id) unless bookmarked_by.nil? or (bookmarked_by =~ /^\d+$/)
        execution = query.gsub!(/execution:(plain|bool|and)/, "") && $1.to_sym
        sorts_string = query.gsub!(/sort:([[\w\d_]+\s+(desc|asc),?]+)/i, "") && $1
        sorts = Hash[sorts_string.split(",").map { |sort| sort.split(/\s/) }] unless sorts_string.nil?
        flagged = query.gsub!(/flagged:(true|false)/, "") && $1 == "true"
        query.gsub!(/\!{2,}\s*/, "") unless query.nil?

      end
      execution = :plain if execution.nil?
      sorts = { created_at: 'desc' } if sorts.blank?
      flagged = false if flagged.nil?
      query = "#{query} flagged:#{flagged}"

      [query, team, author, bookmarked_by, execution, sorts]
    end

    def preprocess_tags(tags)
      tags.collect do |tag|
        preprocess_tag(tag)
      end unless tags.nil?
    end

    def preprocess_tag(tag)
      match = tag.downcase.strip.match(VALID_TAG)
      sanitized_tag = match[0] unless match.nil?
      sanitized_tag
    end

    def process_tags_for_search(tags)
      tags.blank? ? [] : ActiveRecord::Base.connection.select_values(Tag.where(name: tags).select(:id).to_sql).map(&:to_i)
    end

    def already_created_a_protip_for(url)
      existing_protip = ProtipLink.find_by_encoded_url(url)
      existing_protip && existing_protip.protip.try(:created_automagically?)
    end

    def valid_reviewers
      Rails.cache.fetch('valid_protip_reviewers', expires_in: 1.month) do
        if ENV['REVIEWERS']
          User.where(username: YAML.load(ENV['REVIEWERS'])).all
        else
          []
        end
      end
    end

  end

  #######################
  # Homepage 4.0 rewrite
  #######################

  def deindex_search
    Services::Search::DeindexProtip.run(self)
  end

  def index_search
    Services::Search::ReindexProtip.run(self)
  end

  def index_search_after_destroy
    self.tire.update_index
  end

  def unqueue_flagged
    ProcessingQueue.unqueue(self, :auto_tweet)
  end

  def networks
    Network.tagged_with(self.topics)
  end

  def orphan?
    self.networks.blank?
  end

  def update_network(event=:new_protip)
    enqueue(::UpdateNetwork, event, self.public_id, self.score)
  end

  def generate_event(options={})
    unless self.created_automagically? and self.topics.include?("github")
      event_type = self.event_type(options)
      enqueue_in(10.minutes, GenerateEvent, event_type, event_audience(event_type), self.to_event_hash(options), 1.minute)
    end
  end

  def to_event_hash(options={})
    event_hash = to_public_hash.merge({ user: { username: user && user.username }, body: {} })
    event_hash[:created_at] = event_hash[:created_at].to_i
    unless options[:viewer].nil?
      event_hash[:user][:username] = options[:viewer]
      event_hash[:views] = total_views
    end
    unless options[:voter].nil?
      event_hash[:user][:username] = options[:voter]
      event_hash[:voter] = options[:voter]
    end
    event_hash
  end

  def event_audience(event_type)
    audience = {}
    case event_type
    when :protip_view, :protip_upvote
      audience = Audience.user(self.author.id)
    else
      audience = Hash[*[Audience.user_reach(self.author.id), self.networks.any? ? Audience.networks(self.networks.map(&:id)) : Audience.admin(self.slideshare? ? nil : :orphan_protips)].map(&:to_a).flatten(2)]
    end
    audience
  end

  def slideshare?
    self.topics.count == 1 && self.topics.include?("slideshare")
  end

  def event_type(options={})
    if options[:viewer]
      :protip_view
    elsif options[:voter]
      :protip_upvote
    else
      upvotes == 0 ? :new_protip : :trending_protip
    end
  end

  def topic_ids
    self.taggings.joins('inner join tags on taggings.tag_id = tags.id').select('tags.id').map(&:id)
  end

  def to_indexed_json
    to_public_hash.deep_merge(
      {
        trending_score:        trending_score,
        popular_score:         value_score,
        score:                 score,
        upvoters:              upvoters_ids,
        comments_count:        comments.count,
        views_count:           total_views,
        comments:              comments.map do |comment|
          {
            title: comment.title,
            body:  comment.comment,
            likes: comment.likes_cache
          }
        end,
        networks:              networks.map(&:name).map(&:downcase).join(","),
        best_stat:             Hash[*[:name, :value].zip(best_stat.to_a).flatten],
        team:                  user && user.team && {
          name:         user.team.name,
          slug:         user.team.slug,
          avatar:       user.team.avatar_url,
          profile_path: Rails.application.routes.url_helpers.teamname_path(slug: user.team.try(:slug)),
          hiring:       user.team.hiring?
        },
        only_link:             only_link?,
        user:                  user && { user_id: user.id },
        flagged:               flagged?,
        created_automagically: created_automagically?,
        reviewed:              viewed_by_admin?,
        tag_ids:               topic_ids
      }
    ).to_json(methods: [:to_param])
  end

  def user_hash
    user.public_hash(true).select { |k, v| [:username, :name].include? k }.merge(
      {
        profile_url:  user.profile_url,
        avatar:       user.profile_url,
        profile_path: Rails.application.routes.url_helpers.badge_path(user.username),
        about:        user.about
      }
    ) unless user.nil?
  end

  def to_public_hash
    {
      public_id:   public_id,
      kind:        kind,
      title:       Sanitize.clean(title),
      body:        body,
      html:        Sanitize.clean(to_html),
      tags:        topics,
      upvotes:     upvotes,
      url:         path,
      upvote_path: upvote_path,
      link:        link,
      created_at:  created_at,
      featured:    featured,
      user:        user_hash
    }
  end

  def to_public_json
    to_public_hash.to_json
  end

  def flag
    self.inappropriate += 1
  end

  def unflag
    self.inappropriate -= 1
  end

  def flagged?
    self.inappropriate >= MIN_FLAG_THRESHOLD
  end

  def author
    self.user
  end

  def team
    self.user.try(:team)
  end

  def path
    Rails.application.routes.url_helpers.protip_path(public_id)
  end

  def upvote_path
    Rails.application.routes.url_helpers.upvote_protip_path(public_id)
  end

  #link? qa? article?
  KINDS.each do |kind|
    define_method("#{kind}?") do
      self.kind.to_sym == kind
    end
  end

  def created_automagically?
    self.created_by == IMPORTER
  end

  def original?
    !link?
  end

  def tokenized_skills
    @tokenized_skills ||= self.topics.collect { |tag| Skill.tokenize(tag) }
  end

  def to_param
    self.public_id
  end

  #callback from likes after save
  def liked(how_much=nil)
    unless how_much.nil?
      self.upvotes_value= (self.upvotes_value + how_much)
      recalculate_score!
      update_network(:protip_upvote)
    end
    self.save(validate: false)
  end

  def commented
    update_score!(false)
  end

  def reset_likes_cache(like)
    @upvotes = @upvotes_score = nil
  end

  def reset_links_cache(link)
    @valid_links = nil
  end

  def upvoters_ids
    ActiveRecord::Base.connection.select_values(self.likes.select(:user_id).to_sql).map(&:to_i).reject { |id| id == 0 }
  end

  def best_stat
    {
      views:    self.total_views/COUNTABLE_VIEWS_CHUNK,
      upvotes:  self.upvotes,
      comments: self.comments.count,
      hawt:     self.hawt? ? 100 : 0
    }.sort_by { |k, v| -v }.first
  end

  def upvotes
    @upvotes ||= likes.count
  end

  def upvotes=(count)
    @upvotes = count
  end

  def upvotes_value(force=false)
    ((force || self.upvotes_value_cache.nil?) ? ::Like.protips_score(self.id).map(&:like_score).first.to_i : self.upvotes_value_cache)
  end

  def upvotes_value=(value)
    @upvotes_value = self.upvotes_value_cache = value
  end

  #new records get an equivalent of 75 upvotes, after first upvote/recalculate they're back to normal. We also add author's score and random offset for imported ones so they don't have same score
  def upvotes_score
    @upvotes_score ||= begin
                         score = (created_automagically? ? rand()/10 : 0) #make automated tasks that have exactly same timestamp and same author, have different scores
                         score += (self.upvotes_value(true) + (author.try(:score) || 0))
                         score -= team_members_upvotes.map(&:value).reduce(:+) if detect_voting_ring?
                         score + 1
                       end
  end

  MAX_SCORE = 100

  def normalized_upvotes_score
    (upvotes_score * MAX_SCORE) / ([self.class.most_upvotes_for_a_protip.to_f, UPVOTES_SCORE_BENCHMARK].min)
  end

  def cap_score
    self.score = (self.score > MAX_SCORE ? MAX_SCORE : self.score)
  end

  def half_life
    4.days
  end

  def views_score
    self.total_views/COUNTABLE_VIEWS_CHUNK
  end

  def comments_score
    self.comments.collect { |comment| comment.likes_value_cache + comment.author.score }.reduce(:+) || 0
  end

  QUALITY_WEIGHT = 20

  def quality_score
    self.determine_boost_factor! * QUALITY_WEIGHT
  end

  def value_score
    [upvotes_score + views_score + comments_score + quality_score, 0].max
  end

  def calculated_score
    trending_score
  end

  def gravity
    base_gravity = 1.8
    base_gravity += 3.0 if detect_voting_ring?
    base_gravity - upvote_velocity(1.week.ago)
  end

  def upvotes_since(time)
    self.likes.where('created_at > ?', time).count
  end

  def upvote_velocity(since = Time.at(0))
    Rails.logger.ap since

    us = upvotes_since(since)
    Rails.logger.ap us

    more_recent = [self.created_at, since].compact.max
    Rails.logger.ap more_recent

    us / (((Time.now - more_recent).to_i + 1) / 3600.00)
  rescue => e
    Rails.logger.ap(e.message, :error)
    Rails.logger.ap(e.backtrace, :error)

    0.0
  end

  DECENT_ARTICLE_SIZE = 300
  MAX_ARTICLE_BOOST = 3.0
  LINK_PROTIP_PENALTY = -5.0
  ARTICLE_BOOST = 2.0 #200%
  ORIGINAL_CONTENT_BOOST = 1.5
  IMAGE_BOOST = 0.5
  MAX_SCORABLE_IMAGES = 3

  def determine_boost_factor!
    factor = 1
    if article?
      factor += [(body.length/DECENT_ARTICLE_SIZE), MAX_ARTICLE_BOOST].min
    else
      factor += LINK_PROTIP_PENALTY
    end

    unless created_automagically?
      factor += ORIGINAL_CONTENT_BOOST
    end

    factor += [images.count, MAX_SCORABLE_IMAGES].min * IMAGE_BOOST

    self.boost_factor = factor
  end

  def boost_by(factor)
    self.boost_factor *= factor
    #cap_score
  end

  def update_score!(recalculate_quality_score=true)
    recalculate_score!(recalculate_quality_score)
    save(validate: false)
  end

  def recalculate_score!(force=false)
    determine_boost_factor! if force or self.boost_factor.nil? or body_changed? or self.created_at > 1.day.ago
    self.score = calculated_score
  end

  def detect_voting_ring?
    (upvotes < 15) && (upvotes >= 3) && ([team_members_ids_that_upvoted].count/self.upvotes.to_f > 0.7)
  end

  def team_members_ids_that_upvoted
    upvoters_ids & self.author.team_member_ids
  end

  def team_members_upvotes
    self.likes.where(user_id: team_members_ids_that_upvoted)
  end

  def upvote_by(voter, tracking_code, ip_address)
    begin
      unless already_voted?(voter, tracking_code, ip_address) or (self.author.id == voter.try(:id))
        self.likes.create(user: voter, value: voter.nil? ? 1 : adjust_like_value(voter, voter.like_value), tracking_code: tracking_code, ip_address: ip_address)
        generate_event(voter: voter.username) unless voter.nil?
      end
    rescue ActiveRecord::RecordNotUnique
    end
  end

  @valid_links = nil

  def valid_links?
    @valid_links ||= begin
                       self.links.each do |link|
                         return false unless valid_link?(link)
                       end
                       true
                     end
  end

  def invalid_links?
    not valid_links?
  end

  def already_voted?(voter, tracking, ip_address)
    existing_upvote = likes.where(user_id: voter.id).first unless voter.nil?
    existing_upvote = likes.where(tracking_code: tracking).first if existing_upvote.nil? and tracking
    existing_upvote = likes.where(ip_address: ip_address).first if existing_upvote.nil? and voter.nil? and (tracking.nil? || !User.exists?(tracking_code: tracking))

    existing_upvote
  end

  def assign_random_id
    self.public_id = SecureRandom.urlsafe_base64(4).downcase
    assign_random_id unless self.class.where(public_id: self.public_id).blank? #retry if not unique
  end

  def determine_kind
    self.kind = begin
                  if only_link?
                    :link
                  elsif FORMATTERS[:q].match(body) and FORMATTERS[:a].match(body)
                    :qa
                  else
                    :article
                  end
                end
  end

  def assign_title(html)
    if self.link? and self.title.blank?
      self.title = retrieve_title_from_html(html)
    end
  end

  MIN_CONTENT_LENGTH = 30

  def only_link?
    has_featured_image? == false && links.size == 1 && (body.length - link.length) <= MIN_CONTENT_LENGTH
  end

  def non_link_size
    body.length - URI::regexp.match(body)[0].length
  end

  #takes out links from parenthesis so the parenthesis, a valid url character, is not included as part of the url
  def body_without_link_markup
    body && body.gsub(/\((#{URI::regexp})\)/, '\1')
  end

  def links
    if self.body_changed?
      @links ||= (URI::extract(body_without_link_markup || "", ['http', 'https', 'mailto', 'ftp']))
    else
      self.protip_links.map(&:url)
    end
  end

  def images
    if self.new_record?
      self.links.select { |link| ProtipLink.is_image? link }
    else
      protip_links.where('kind in (?)', ProtipLink::IMAGE_KINDS).map(&:url)
    end
  end

  def retrieve_title_from_html(html)
    Nokogiri::XML.fragment(html.xpath("//title").map(&:text).join).text.force_encoding('ASCII-8BIT').gsub(/\P{ASCII}/, '')
  end

  def upvote_ancestor(link_identifier, link)
    ProtipLink.where(identifier: link_identifier).order('created_at ASC').first.try(:tap) do |ancestor|
      if (ancestor.protip != self) and (ancestor.protip.author.id != self.author.id) and (ancestor.url == link)
        ancestor.protip.upvote_by(self.user, self.user.tracking_code, DEFAULT_IP_ADDRESS) unless ancestor.nil? || ancestor.protip.nil?
        break
      end
    end
  end

  def process_links
    if self.body_changed?
      self.links.each do |link|
        link_identifier = ProtipLink.generate_identifier(link)
        existing_link = self.protip_links.find_or_initialize_by_identifier(identifier: link_identifier, url: link.first(254))

        if existing_link.new_record?
          upvote_ancestor(link_identifier, link) unless self.user.nil?
        end
      end
      #delete old links
      self.protip_links.reject { |link| link.changed? }.map(&:destroy)
    end
  end

  def extract_data_from_links
    self.links.each do |link|
      html = Nokogiri.parse(open(link))
      #auto_tag(html) if self.tags.empty?
      assign_title(html) if self.title.blank?
    end if need_to_extract_data_from_links
  end

  #
  # This should eventually be done inline as they type in a protip. We should utilize natural language processing and
  # coding/technology jargon domain to determine appropriate tags automatically. Perhaps use AlchemyAPIs to tag protips
  # with people, authors, places and other useful dimension.
  #
  def auto_tag(html = nil)
    if self.link? and self.topics.blank?
      self.topics = Taggers.tag(html, self.links.first)
    end
  end

  def owned_by?(user)
    self.user == user
  end

  alias_method :owner?, :owned_by?

  def tag_user
    self.users = [self.user.try(:username)] if self.users.blank?
  end

  def reassign_to(user)
    self.user = user
    tag_user
  end

  def tags
    topics + users
  end

  def link
    self.links.first
  end

  def reformat_tags!
    if self.topics.count == 1 && self.topics.first =~ /\s/
      self.topics = self.topics.first.split(/\s/)
    end
  end

  def sanitize_tags!
    new_topics = self.topics.reject { |tag| tag.blank? }.map do |topic|
      sanitized_topic = self.class.preprocess_tag(topic)
      invalid_topic = topic.match("^((?!#{VALID_TAG}).)*$") && $1
      errors[:topics] << "The tag '#{topic}' has invalid characters: #{invalid_topic unless invalid_topic.nil?}" if sanitized_topic.nil?
      sanitized_topic
    end
    new_topics = new_topics.compact.uniq
    self.topics = new_topics if topics.blank? or topics_changed?
  end

  def topics_changed?
    self.topics_tags.map(&:name) != self.topics
  end

  def viewed_by(viewer)
    epoch_now = Time.now.to_i
    REDIS.incr(impressions_key)
    if viewer.is_a?(User)
      REDIS.zadd(user_views_key, epoch_now, viewer.id)
      generate_event(viewer: viewer.username) unless viewer_ids(5.minutes.ago.to_i).include? viewer.id.to_s
      index_search if viewer.admin?
    else
      REDIS.zadd(user_anon_views_key, epoch_now, viewer)
      count = REDIS.zcard(user_anon_views_key)
      REDIS.zremrangebyrank(user_anon_views_key, -(count - 100), -1) if count > 100
    end

    update_score! if (total_views % COUNTABLE_VIEWS_CHUNK) == 0
  end

  def viewed_by?(viewer)
    if viewer.is_a?(User)
      !REDIS.zrank(user_views_key, viewer.id).nil?
    else
      !REDIS.zrank(user_anon_views_key, viewer).nil?
    end
  end

  def viewed_by_admin?
    self.class.valid_reviewers.each do |reviewer|
      return true if self.viewed_by?(reviewer)
    end

    false
  end

  def impressions_key
    "protip:#{public_id}:impressions"
  end

  def user_views_key
    "protip:#{public_id}:views"
  end

  def user_anon_views_key
    "protip:#{public_id}:views:anon"
  end

  def viewers(since=0)
    viewer_ids = viewer_ids(since)
    User.where(id: viewer_ids).all
  end

  def viewer_ids(since=0)
    epoch_now = Time.now.to_i
    REDIS.zrangebyscore(user_views_key, since, epoch_now)
  end

  def total_views(epoch_since = 0)
    if epoch_since.to_i == 0
      REDIS.get(impressions_key).to_i
    else
      epoch_now = Time.now.to_i
      epoch_since = epoch_since.to_i
      REDIS.zcount(user_views_key, epoch_since, epoch_now) + REDIS.zcount(user_anon_views_key, epoch_since, epoch_now)
    end
  end

  def queued_for?(queue_name)
    ProcessingQueue.queued?(self, queue_name)
  end

  def best_matching_job
    matching_jobs.first
  end

  def matching_jobs
    if self.user.team && self.user.team.hiring?
      self.user.team.best_positions_for(self.user)
    else
      Opportunity.based_on(self.topics)
    end
  end

  def to_html
    CFM::Markdown.render self.body
  end

  protected
  def check_links
    errors[:body] << "one or more of the links are invalid or not publicly reachable/require login" unless valid_links?
  end

  private
  def need_to_extract_data_from_links
    self.topics.blank? || self.title.blank?
  end

  def adjust_like_value(user, like_value)
    user.is_a?(User) && self.author.team_member_of?(user) ? [like_value/2, 1].max : like_value
  end

  def analyze_spam
    Resque.enqueue(AnalyzeSpam, { id: id, klass: self.class.name })
  end

end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: protips
#
#  id                  :integer          not null, primary key
#  public_id           :string(255)      indexed
#  kind                :string(255)
#  title               :string(255)
#  body                :text
#  user_id             :integer          indexed
#  created_at          :datetime
#  updated_at          :datetime
#  score               :float
#  created_by          :string(255)      default("self")
#  featured            :boolean          default(FALSE)
#  featured_at         :datetime
#  upvotes_value_cache :integer          default(0), not null
#  boost_factor        :float            default(1.0)
#  inappropriate       :integer          default(0)
#  likes_count         :integer          default(0)
#
# Indexes
#
#  index_protips_on_public_id  (public_id)
#  index_protips_on_user_id    (user_id)
#
