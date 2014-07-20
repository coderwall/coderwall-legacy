class ProcessTeam < Struct.new(:process_type, :team_id)
  extend ResqueSupport::Basic

  @queue = 'LOW'

  def perform
    team = Team.find(team_id)
    case process_type.to_sym
      when :recalculate
        if team.team_members.size <= 0
          team.destroy
          REDIS.zrem(Team::LEADERBOARD_KEY, team.id.to_s)
        else
          team.recalculate!
          if team.team_members.size < 3
            REDIS.zrem(Team::LEADERBOARD_KEY, team.id.to_s)
          else
            REDIS.zadd(Team::LEADERBOARD_KEY, team.score.to_f, team.id.to_s)
          end
        end
      when :reindex
        Team.all.each do |team|
          enqueue(IndexTeam, team.id)
        end
    end
  end
end