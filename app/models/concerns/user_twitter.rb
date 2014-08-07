module UserTwitter
  extend ActiveSupport::Concern

  included do
    def lanyrd_identity
      "lanyrd:#{twitter}" if twitter
    end

    def twitter_identity
      "twitter:#{twitter}" if twitter
    end

    def clear_twitter!
      self.twitter = nil
      self.twitter_token = nil
      self.twitter_secret = nil
      save!
    end
  end
end