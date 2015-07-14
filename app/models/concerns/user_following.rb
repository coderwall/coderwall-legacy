module UserFollowing
  extend ActiveSupport::Concern

  def build_follow_list!
    if twitter_id
      Redis.current.del(followers_key)
      people_user_is_following = Twitter.friend_ids(twitter_id.to_i)
      people_user_is_following.each do |id|
        Redis.current.sadd(followers_key, id)
        if user = User.find_by_twitter_id(id.to_s)
          self.follow(user)
        end
      end
    end
  end

  def follow(user)
    super(user) rescue ActiveRecord::RecordNotUnique
  end

  def member_of?(network)
    self.following?(network)
  end

  def following_team?(team)
    followed_teams.collect(&:team_id).include?(team.id)
  end

  def follow_team!(team)
    followed_teams.create!(team: team)
    generate_event(team: team)
  end

  def unfollow_team!(team)
    followed_teams = self.followed_teams.where(team_id: team.id)
    followed_teams.destroy_all
  end

  def teams_being_followed
    Team.find(followed_teams.collect(&:team_id)).sort { |x, y| y.score <=> x.score }
  end

  def following_users_ids
    self.following_users.pluck(:id)
  end

  def following_teams_ids
    self.followed_teams.pluck(:team_id)
  end

  def following_team_members_ids
    User.where(team_id: self.following_teams_ids).pluck(:id)
  end

  def following_networks_tags
    self.following_networks.map(&:tags).uniq
  end

  def following
    @following ||= begin
      ids = Redis.current.smembers(followers_key)
      User.where(twitter_id: ids).order("badges_count DESC").limit(10)
    end
  end

  def following_in_common(user)
    @following_in_common ||= begin
      ids = Redis.current.sinter(followers_key, user.followers_key)
      User.where(twitter_id: ids).order("badges_count DESC").limit(10)
    end
  end

  def followed_repos(since=2.months.ago)
    Redis.current.zrevrange(followed_repo_key, 0, since.to_i).collect { |link| Users::Github::FollowedRepo.new(link) }
  end

  def networks
    self.following_networks
  end

  def followers_since(since=Time.at(0))
    self.followers_by_type(User.name).where('follows.created_at > ?', since)
  end

  def subscribed_to_topic?(topic)
    tag = ActsAsTaggableOn::Tag.find_by_name(topic)
    tag && following?(tag)
  end

  def subscribe_to(topic)
    tag = ActsAsTaggableOn::Tag.find_by_name(topic)
    follow(tag) unless tag.nil?
  end

  def unsubscribe_from(topic)
    tag = ActsAsTaggableOn::Tag.find_by_name(topic)
    stop_following(tag) unless tag.nil?
  end

  def protip_subscriptions
    following_tags
  end

  def join(network)
    self.follow(network)
  end

  def leave(network)
    self.stop_following(network)
  end
end
