class TwitterProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  index 'username', unique: true, background: true

  field :username, type: String
  field :user_id, type: String

  embeds_many :tweets

  class << self
    def for_username(username)
      where(username: username).first || create!(username: username)
    end
  end

  def refresh_timeline!
    since_id = most_recent_tweet && most_recent_tweet.tweet_id || nil
    TwitterClient.timeline_for(username, since_id).reverse.each do |grackle_tweet|
      tweets.build(Tweet.to_hash(grackle_tweet))
    end
    save!
  end

  def most_recent_tweet
    tweets.last
  end

  def recent_links
    urls = []
    tweets.each do |tweet|
      tweet.text.split(/[ |"]/).collect(&:strip).select { |part| part =~ /^https?:/ }.each do |tweet_url|
        urls << tweet_url
      end if tweet.created_at > 10.days.ago
    end
    urls.uniq
  end

end