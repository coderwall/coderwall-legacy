class Tweet
  include Mongoid::Document

  field :text
  field :tweet_id
  field :created_at, type: Time

  embedded_in :twitter_profile

  def self.to_hash(tweet)
    {
      tweet_id:                tweet['id'],
      created_at:              tweet['created_at'],
      text:                    tweet['text'],
      retweeted:               tweet['retweeted'],
      retweet_count:           tweet['retweet_count'],
      favorited:               tweet['favorited'],
      in_reply_to_screen_name: tweet['in_reply_to_screen_name'],
      in_reply_to_user_id:     tweet['in_reply_to_user_id']
    }
  end
end