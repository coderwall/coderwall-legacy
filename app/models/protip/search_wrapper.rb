class Protip::SearchWrapper
  attr_accessor :item

  def initialize(item)
    @item = item.is_a?(Protip) ? item.to_public_hash : item
  end

  def username
    item[:user][:username]
  end

  def profile_url
    avatar
  end

  def avatar
    item[:user][:avatar]
  end

  def already_voted?(_current_user, _tracking, _ip_address)
    false
  end

  def user
    self # proxy user calls to self
  end

  def owner?(user)
    return false if user.nil?
    username == user.username
  end

  def upvotes
    item[:upvotes]
  end

  def topics
    (item[:tags] - [item[:user][:username]]).uniq
  end

  def only_link?
    item[:only_link] == true
  end

  def link
    item[:link]
  end

  def title
    item[:title]
  end

  def to_s
    public_id # for url creation
  end

  def public_id
    item[:public_id]
  end

  def created_at
    item[:created_at]
  end

  def self.model_name
    Protip.model_name
  end

  def viewed_by?(viewer)
    singleton.viewed_by?(viewer)
  end

  def total_views
    singleton.total_views
  end

  def team_profile_url
    item[:team][:profile_url]
  end

  def singleton
    item.is_a?(Protip) ? item : Protip.new(public_id: public_id)
  end
end
