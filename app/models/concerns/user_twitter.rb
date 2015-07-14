module UserTwitter
  extend ActiveSupport::Concern

  def clear_twitter!
    self.twitter = nil
    self.twitter_token = nil
    self.twitter_secret = nil
    save!
  end
end
