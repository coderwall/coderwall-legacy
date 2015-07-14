module UserRedisKeys
  extend ActiveSupport::Concern

  def repo_cache_key
    username
  end

  def daily_cache_key
    "#{repo_cache_key}/#{Date.today.to_time.to_i}"
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

  def followers_key
    "user:#{id}:followers"
  end

  #Let put these here for now
  def bitbucket_identity
    "bitbucket:#{bitbucket}" unless bitbucket.blank?
  end

  def speakerdeck_identity
    "speakerdeck:#{speakerdeck}" if speakerdeck
  end

  def slideshare_identity
    "slideshare:#{slideshare}" if slideshare
  end

  def github_identity
    "github:#{github}" if github
  end

  def linkedin_identity
    "linkedin:#{linkedin_token}::#{linkedin_secret}" if linkedin_token
  end

  def lanyrd_identity
    "lanyrd:#{twitter}" if twitter
  end

  def twitter_identity
    "twitter:#{twitter}" if twitter
  end
end