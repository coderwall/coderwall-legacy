module LeaderboardRedisRank
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def top(page = 1, total = 50, _country = nil)
      end_range = (page * total) - 1
      start_range = (end_range - total) + 1
      ids = REDIS.zrevrange(Team::LEADERBOARD_KEY, start_range, end_range)
      Team.find(ids).sort_by(&:rank)
    end
  end

  def next_highest_competitors(number = 2)
    @higher_competitor ||= Team.find(higher_competitors(number)).sort_by(&:rank)
  end

  def higher_competitors(number = 1)
    low = [rank - number - 1, 0].max
    high = [rank - 2, 0].max
    total_member_count >= 3 && rank - 1 != low ? REDIS.zrevrange(Team::LEADERBOARD_KEY, low, high) : []
  end

  def lower_competitors(number = 1)
    low = [rank, 0].max
    high = [rank + number - 1, 0].max
    total_member_count >= 3 && rank != high ? REDIS.zrevrange(Team::LEADERBOARD_KEY, low, high) : []
  end

  def next_lowest_competitors(number = 2)
    @lower_competitor ||= Team.find(lower_competitors(number)).sort_by(&:rank)
  end

  def rank
    @rank ||= (REDIS.zrevrank(Team::LEADERBOARD_KEY, id.to_s) || -1).to_i + 1
  end
end
