class Fact < ActiveRecord::Base
  serialize :tags, Array
  serialize :metadata, Hash

  def self.append!(identity, owner, name, date, url, tags, metadata = nil)
    fact             = Fact.where(identity: identity).first || Fact.new(identity: identity)
    fact.tags        = (fact.tags.nil? ? tags : (fact.tags + tags).uniq)
    fact.owner       = owner.downcase
    fact.name        = name
    fact.url         = url
    fact.relevant_on = date
    fact.metadata    = metadata
    fact.save!
    fact
  end

  def self.add_language_to_repo!(repo_url, language)
    fact = Fact.where(url: repo_url).first
    fact.tags << language
    fact.metadata[:languages] << language
    fact.save!
  end

  def self.create_or_update!(fact)
    existing_fact = Fact.where(identity: fact.identity).first

    if existing_fact
      existing_fact.merge!(fact)
    else
      fact.save!
    end
  end

  def merge!(another_fact)
    self.tags        = (another_fact.tags.nil? ? another_fact.tags : (tags + another_fact.tags).uniq)
    self.owner       = another_fact.owner.downcase
    self.name        = another_fact.name
    self.url         = another_fact.url
    self.relevant_on = another_fact.relevant_on
    metadata.merge!(another_fact.metadata)
    self.save!
    self
  end

  attr_writer :context

  attr_reader :context

  def tagged?(*required_tags)
    required_tags.each do |tag|
      return false unless tags.include?(tag)
    end
    true
  end

  def user
    service, username = owner.split(':')
    User.with_username(username, service)
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: facts
#
#  id          :integer          not null, primary key
#  identity    :string(255)      indexed
#  owner       :string(255)      indexed
#  name        :string(255)
#  url         :string(255)
#  tags        :text
#  metadata    :text
#  relevant_on :datetime
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_facts_on_identity  (identity)
#  index_facts_on_owner     (owner)
#
