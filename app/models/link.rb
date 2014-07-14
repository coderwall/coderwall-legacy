class Link
  class AlreadyLinkForUser < RuntimeError;
  end;
  class InvalidUrl < RuntimeError;
  end;

  include Mongoid::Document
  include Mongoid::Timestamps

  index({url: 1}, {unique: true})
  index({user_ids: 1})
  index({featured_on: 1})

  field :url, type: String
  field :user_ids, type: Array, default: []
  field :user_count, type: Integer, default: 0
  field :user_interests, type: Array, default: []
  field :score, type: Integer
  field :domain, type: String
  field :featured_on, type: DateTime
  field :embedded_data

  before_create :extract_host
  before_save :clean_collections

  scope :popular, where(user_count: { '$gt' => 1 }).where(score: { '$gt' => 7 })
  scope :featured, where(featured_on: { '$exists' => true }).order_by([[:featured_on, :desc], [:score, :desc]])
  scope :not_featured, where(featured_on: { '$exists' => false })

  class << self
    #def feature_popular_links!
      #popular.not_featured.all.each do |link|
        #link.feature!
      #end
    #end

    def register_for_user!(url, user)
      link = Link.for_url(url) || begin
        url = expand_url(url)
        Link.for_url(url) || Link.new(url: url)
      end
      link.add_user(user)
      link.save!
      link
    end

    def for_url(url)
      where(url: url).first
    end

    def for_user(user)
      user_id = user.is_a?(User) ? user.id : user
      where(:user_ids.in => [user_id])
    end

    def expand_url(url)
      r = Net::HTTP.get_response(URI.parse(url))
      if r['location']
        return r['location']
      else
        return url
      end
    rescue Exception => ex
      Rails.logger.error(ex.message)
      raise InvalidUrl
    end
  end

  #def feature!
    #querystring        = QueryString.stringify({ url: url })
    #response           = RestClient.get("http://api.embed.ly/1/oembed?#{querystring}")
    #self.embedded_data = JSON.parse(response)
    #self.featured_on   = Date.today
    #save!
  #end

  def add_user(user)
    raise AlreadyLinkForUser if knows?(user)
    self.score = (self.score || 0) + score_for_user(user)
    self.user_ids << user.id
    self.user_interests << user.interests
  end

  def knows?(user)
    self.user_ids.include?(user.id)
  end

  def title
    embedded_data['title']
  end

  def description
    embedded_data['description']
  end

  def thumbnail?
    !thumbnail_url.nil?
  end

  def thumbnail_url
    embedded_data['thumbnail_url']
  end

  private
  def extract_host
    self.domain = URI.parse(url).host if url
  rescue Exception => ex
    Rails.logger.warn("Unable to extract host from #{url}")
  end

  def score_for_user(user)
    [(user.badges_count * 0.30).round, 1].max
  end

  def clean_collections
    self.user_count = user_ids.size
    self.user_interests.flatten!
  end
end
