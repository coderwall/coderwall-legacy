module UserRedisKeys
  extend ActiveSupport::Concern

  included do
    def repo_cache_key
      username
    end

    def daily_cache_key
      "#{username}/#{Date.today.to_time.to_i}"
    end

    def timeline_key
      @timeline_key ||= "user:#{id}:timeline"
    end

    def impressions_key
      "user:#{id}:impressions"
    end

    def user_views_key
      "user:#{id}:views"
    end

    def user_anon_views_key
      "user:#{id}:views:anon"
    end

    def followed_repo_key
      "user:#{id}:following:repos"
    end

  end
end