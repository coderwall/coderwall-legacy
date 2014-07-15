# encoding: utf-8
class Network < ActiveRecord::Base
  include Tire::Model::Search
  include ResqueSupport::Basic

  settings analysis: { analyzer: { exact_term_search: { 'type'      => 'keyword',
                                                        'tokenizer' => 'keyword' } } }
  mapping show: { properties: {
    name:          { type: 'string', boost: 100, index: 'not_analyzed' },
    protips_count: { type: 'integer', index: 'not_analyzed' },
    upvotes:       { type: 'integer', index: 'not_analyzed' },
    upvotes_score: { type: 'float', index: 'not_analyzed' },
    tags:          { type: 'string', boost: 80, index: 'not_analyzed' },
    members:       { properties: {
      username:     { type: 'string', index: 'not_analyzed' },
      user_id:      { type: 'integer', boost: 40, index: 'not_analyzed' },
      profile_path: { type: 'string', index: 'not_analyzed' },
      profile_url:  { type: 'string', index: 'not_analyzed' },
    } } } }

  attr_taggable :tags
  acts_as_followable
  attr_accessor :resident_expert
  has_many :network_experts, autosave: true, dependent: :destroy

  validates :slug, uniqueness: true

  before_validation :create_slug!
  after_validation :tag_with_name!

  before_save :assign_mayor!
  before_save :correct_tags
  before_save :cache_counts!
  after_create :assign_members
  after_save :cleanup_orphans

  scope :most_protips, order('protips_count_cache DESC')
  scope :featured, where(featured: true)

  class << self
    def slugify(name)
      if !!(name =~ /\p{Latin}/)
        name.to_s.downcase.gsub(/[^a-z0-9]+/i, '-').chomp('-')
      else
        name.to_s.gsub(/\s/, '-')
      end
    end

    def unslugify(slug)
      slug.gsub(/\-/, ' ')
    end

    def all_with_tag(tag_name)
      Network.tagged_with(tag_name)
    end

    def networks_for_tag(tag_name)
      all_with_tag(tag_name)
    end

    def top_tags_not_networks
      top_tags.where('tags.name NOT IN (?)', Network.all.map(&:name))
    end

    def top_tags_not_in_any_networks
      top_tags.where('tags.name NOT IN (?)', Network.all.map(&:tags).flatten)
    end

    def top_tags
      Tagging.joins('inner join tags on tags.id = taggings.tag_id').select('distinct(name), count(name)').order('count(name) DESC').group('tags.name').where("context = 'topics'")
    end
  end

  def to_param
    slug
  end

  def cache_counts!
    self.protips_count_cache = protips.count
  end

  def create_slug!
    self.slug = self.class.slugify(name)
  end

  def tag_with_name!
    unless tags.include? name
      self.tags = (tags + [name, slug])
    end
  end

  def correct_tags
    if self.tags_changed?
      self.tags = tags.uniq.select { |tag| Tag.exists?(name: tag) }.reject { |tag| (tag != name) && Network.exists?(name: tag) }
    end
  end

  def tags_changed?
    tags_tags.map(&:name) != tags
  end

  def protips_tags_with_count
    protips.joins('inner join taggings on taggings.taggable_id = protips.id').joins('inner join tags on taggings.tag_id = tags.id').where("taggings.taggable_type = 'Protip' AND taggings.context = 'topics'").select('tags.name, count(tags.name)').group('tags.name').order('count(tags.name) DESC')
  end

  def ordered_tags
    protips_tags_with_count.having('count(tags.name) > 5').map(&:name) & tags
  end

  def potential_tags
    protips_tags_with_count.map(&:name).uniq
  end

  def mayor
    @mayor ||= network_experts.where(designation: 'mayor').last.try(:user)
  end

  def assign_mayor!
    candidate = in_line_to_the_throne.first
    unless candidate.nil?
      Rails.logger.debug "finding a mayor among: #{tags}"
      person_with_most_upvoted_protips_on_topic = User.find(candidate.user_id)
      Rails.logger.debug "mayor for #{name} found: #{person_with_most_upvoted_protips_on_topic.username}"

      # if self.mayor && person_with_most_upvoted_protips_on_topic && person_with_most_upvoted_protips_on_topic.id != self.mayor.id
      #  enqueue(GenerateEvent, :new_mayor, Hash[*[Audience.network(self.id), Audience.admin].map(&:to_a).flatten(2)], self.to_event_hash(mayor: person_with_most_upvoted_protips_on_topic), 30.minutes)
      # end

      network_experts.build(user: person_with_most_upvoted_protips_on_topic, designation: :mayor)
    end
  end

  def to_event_hash(options = {})
    { user:    { username: options[:mayor] && options[:mayor].try(:username) },
      network: { name: name, url: Rails.application.routes.url_helpers.network_path(slug) } }
  end

  def resident_expert
    @resident ||= network_experts.where(designation: 'resident_expert').last.try(:user)
  end

  def resident_expert=(user)
    network_experts.build(designation: 'resident_expert', user_id: user.id)
  end

  def to_indexed_json
    to_public_hash.to_json
  end

  def to_public_hash
    {
      name:          name,
      protips_count: kind,
      title:         title,
      body:          body,
      tags:          topics,
      upvotes:       upvotes,
      url:           path,
      upvote_path:   upvote_path,
      link:          link,
      created_at:    created_at,
      user:          user_hash
    }
  end

  def protips
    @protips ||= Protip.tagged_with(tags, on: :topics)
    # @protips ||= Protip.search(nil, self.tags)
  end

  def upvotes
    protips.joins('inner join likes on likes.likable_id = protips.id').where("likes.likable_type = 'Protip'").select('count(*)').count
  end

  def most_upvoted_protips(limit = nil, offset = 0)
    Protip.search_trending_by_topic_tags('sort:upvotes desc', tags, offset, limit)
  end

  def new_protips(limit = nil, offset = 0)
    Protip.search('sort:created_at desc', tags, page: offset, per_page: limit)
  end

  def featured_protips(limit = nil, offset = 0)
    # self.protips.where(featured: true)
    Protip.search('featured:true', tags, page: offset, per_page: limit)
  end

  def flagged_protips(limit = nil, offset = 0)
    Protip.search('flagged:true', tags, page: offset, per_page: limit)
  end

  def highest_scored_protips(limit = nil, offset = 0, field = :trending_score)
    Protip.search("sort:#{field} desc", tags, page: offset, per_page: limit)
  end

  def mayor_protips(limit = nil, offset = 0)
    Protip.search_trending_by_user(mayor.username, nil, tags, offset, limit)
  end

  def expert_protips(limit = nil, offset = 0)
    Protip.search_trending_by_user(resident_expert.username, nil, tags, offset, limit)
  end

  def members(limit = -1, offset = 0)
    members_scope = User.where(id: Follow.for_followable(self).select(:follower_id)).offset(offset)
    limit > 0 ? members_scope.limit(limit) : members_scope
  end

  def new_members(limit = nil, offset = 0)
    User.where(id: Follow.for_followable(self).select(:follower_id).where('follows.created_at > ?', 1.week.ago)).limit(limit).offset(offset)
  end

  def ranked_members(limit = 15)
    in_line_to_the_throne.limit(limit).map(&:user)
  end

  def in_line_to_the_throne
    protips.select('protips.user_id, SUM(protips.score) AS total_score').group('protips.user_id').order('SUM(protips.score) DESC').where('upvotes_value_cache > 0')
  end

  def resident_expert_from_env
    ENV['RESIDENT_EXPERTS'].split(',').each do |expert_config|
      network, resident_expert = expert_config.split(/:/).map(&:strip)
      return User.with_username(resident_expert) if network == slug
    end unless ENV['RESIDENT_EXPERTS'].nil?
    nil
  end

  def assign_members
    Skill.where(name: tags).select('DISTINCT(user_id)').map(&:user).each do |member|
      member.join(self)
    end
  end

  def cleanup_orphans
    ProcessingQueue.queue(:orphan_protips).each do |orphan|
      if orphan.queueable && orphan.queueable.networks.any?
        ProcessingQueue.unqueue(orphan.queueable, :orphan_protips)
      end
    end
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: networks
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  slug                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  protips_count_cache :integer          default(0)
#  featured            :boolean          default(FALSE)
#
