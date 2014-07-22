class ProcessTeamJob
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(process_type, team_id)
    team = Team.find(team_id)
    case process_type
      when 'recalculate'
        if team.team_members.size <= 0
          team.destroy
          Redis.current.zrem(Team::LEADERBOARD_KEY, team.id.to_s)
        else
          team.recalculate!
          if team.team_members.size < 3
            Redis.current.zrem(Team::LEADERBOARD_KEY, team.id.to_s)
          else
            Redis.current.zadd(Team::LEADERBOARD_KEY, team.score.to_f, team.id.to_s)
          end
        end
      when 'reindex'
        Team.all.each do |team|
          IndexTeamJob.perform_async(team.id)
        end
    end
  end
end