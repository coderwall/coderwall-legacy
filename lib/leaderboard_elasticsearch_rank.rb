module LeaderboardElasticsearchRank
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    @@ranks = nil

    def rank_teams
      i = 0
      @@ranks ||= []
      teams = top(1, Team.count)
      teams.is_a?(Team::SearchResultsWrapper) ? {} : teams.reduce(Hash.new(0)) { |h, team| h[team.id.to_s] = (i = i + 1); @@ranks[i] = Team::SearchResultsWrapper.new(team, i); h }
    end

    def ranked_teams
      @@ranked_teams ||= Rails.cache.fetch('teams_ranked_teams', expires_in: 1.hour) { rank_teams }
    end

    def ranks
      @@ranks ||= Rails.cache.fetch('teams_ranks', expires_in: 1.hour) { (rank_teams && @@ranks) }
    end

    def team_rank(team)
      ranked_teams[team.id.to_s] || 0
    end

    def top(page = 1, total = 50, _country = nil)
      Team.search('', nil, page, total)
    end
  end

  def next_highest_competitors(number = 2)
    @higher_competitor ||= Team.ranks[rank - number..rank - 1].compact
  end

  def higher_competitors(number = 1)
    Team.ranks[rank - number..rank - 1].compact
  end

  def lower_competitors(number = 1)
    Team.ranks[rank + 1..rank + number].compact
  end

  def next_lowest_competitors(number = 2)
    @lower_competitor ||= Team.ranks[rank + 1..rank + number].compact
  end

  def rank
    @rank ||= Team.team_rank(self)
  end
end
