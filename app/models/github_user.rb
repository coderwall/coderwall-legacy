class GithubUser
  include Mongoid::Document

  field :github_id
  field :avatar_url
  field :login
  field :gravatar

  after_initialize :extract_gravatar_from_avatar_url
  before_save :extract_gravatar_from_avatar_url

  after_initialize :extract_github_id
  before_save :extract_github_id

  embedded_in :personable, polymorphic: true

  def extract_github_id
    temp_id = attributes['id'] || attributes['_id']
    if github_id.nil? && temp_id.is_a?(Fixnum)
      self.github_id = temp_id
      attributes.delete '_id'
      attributes.delete 'id'
    end
  end

  def extract_gravatar_from_avatar_url
    if attributes['avatar_url'] && attributes['avatar_url'] =~ /avatar\/([\w|\d]*)\?/i
      self.gravatar = attributes['avatar_url'].match(/avatar\/([\w|\d]*)\?/i)[1]
      attributes.delete 'avatar_url'
    end
  end
end
