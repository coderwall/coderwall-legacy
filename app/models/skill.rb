class Skill < ActiveRecord::Base
  never_wastes

  SPACE = ' '
  BLANK = ''

  belongs_to :user
  has_many :endorsements

  validates_presence_of :tokenized
  validates_presence_of :user_id
  validates_uniqueness_of :tokenized, scope: [:user_id, :deleted]

  before_validation :tokenize_name
  before_create :scrub_name
  before_create :apply_facts
  after_create :generate_event

  serialize :repos, Array
  serialize :attended_events, Array
  serialize :speaking_events, Array

  default_scope where(deleted: false)

  class << self
    def tokenize(value)
      v = value.to_s.gsub('&', 'and').downcase.gsub(/\s|\./, BLANK)
      v = 'nodejs' if v == 'node'
      Sanitize.clean(v)
    end

    def deleted?(user_id, skill_name)
      Skill.with_deleted.where(user_id: user_id, name: skill_name, deleted: true).any?
    end
  end

  def merge_with(another_skill)
    if another_skill.user_id == self.user_id
      another_skill.endorsements.each do |endorsement|
        self.endorsed_by(endorsement.endorser)
      end
      self.repos           += another_skill.repos
      self.attended_events += another_skill.attended_events
      self.speaking_events += another_skill.speaking_events
    end
  end

  def endorsed_by(endorser)
    # endorsed is only in here during migration of endorsement to skill
    endorsements.create!(endorser: endorser, endorsed: self.user, specialty: self.name)
  end

  def has_endorsements?
    endorsements_count > 0
  end

  def endorsed_by?(user)
    endorsements.where(endorsing_user_id: user.id).any?
  end

  def has_repos?
    repos.size > 0
  end

  def has_events?
    speaking_events.size > 0 || attended_events.size > 0
  end

  def matching_badges_in(badges)
    badges.select { |badge| badge.tokenized_skill_name == tokenized }
  end

  def matching_protips_in(protips)
    protips.select { |protip| protip.original? && protip.tokenized_skills.include?(tokenized) }
  end

  def protips
    @protips ||= matching_protips_in(user.protips)
  end

  def has_protips?
    !protips.empty?
  end

  def locked?
    return false #no longer lock skills
  end

  def trending_protips
    protips.select { |protip| protip.upvotes >= 5 }
  end

  def deletable?
    (endorsements_count + repos.size + speaking_events.size + badges_count) <= 0
  end

  def endorse_message
    "#{user.short_name} needs just #{3 - endorsements.size} more endorsements to unlock #{name}"
  end

  def apply_facts(facts = nil)
    facts = user.facts if facts.nil?
    repos.clear
    attended_events.clear
    speaking_events.clear
    facts.each do |fact|
      associate_repo_fact(fact)
      associate_event_fact(fact)
    end
    self.weight = endorsements_count + repos.count + (speaking_events.count * 2) + attended_events.count + (badges_count * 3)
  end

  def generate_event
    GenerateEventJob.perform_async(self.event_type, Audience.user_reach(self.user.id), self.to_event_hash)
  end

  def to_event_hash
    { skill: { name: self.name, add_path: Rails.application.routes.url_helpers.add_skill_path(skill: { name: self.name }) },
      user:  { username: self.user.username } }
  end

  def event_type
    :new_skill
  end

  def badges_count
    matching_badges_in(user.badges).size
  end

  def associate_repo_fact(fact)
    if fact.tagged?('personal', 'repo', 'original')
      tokenized_tags = fact.tags.map { |t| Skill.tokenize(t) }

      if tokenized_tags.include?(tokenized)
        self.repos << { name: fact.name, url: fact.url }
      end
    end
  end

  def associate_event_fact(fact)
    if fact.tagged?('event')
      tokenized_tags = fact.tags.map { |t| Skill.tokenize(t) }
      if tokenized_tags.include?(tokenized)
        if fact.tagged?('spoke')
          self.speaking_events << { name: fact.name, url: fact.url }
        else
          self.attended_events << { name: fact.name, url: fact.url }
        end
      end
    end
  end

  protected

  def tokenize_name
    self.tokenized = self.class.tokenize(name) if name_changed?
  end

  def scrub_name
    self.name = name.strip
  end
end

# == Schema Information
#
# Table name: skills
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  name               :string(255)      not null
#  endorsements_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  tokenized          :string(255)
#  weight             :integer          default(0)
#  repos              :text
#  speaking_events    :text
#  attended_events    :text
#  deleted            :boolean          default(FALSE), not null
#  deleted_at         :datetime
#
# Indexes
#
#  index_skills_on_deleted_and_user_id  (deleted,user_id)
#  index_skills_on_user_id              (user_id)
#
