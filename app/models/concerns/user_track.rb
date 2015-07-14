module UserTrack
  extend ActiveSupport::Concern

  def track!(name, data = {})
    user_events.create!(name: name, data: data)
  end

  def track_user_view!(user)
    track!('viewed user', user_id: user.id, username: user.username)
  end

  def track_signin!
    track!('signed in')
  end

  def track_viewed_self!
    track!('viewed self')
  end

  def track_team_view!(team)
    track!('viewed team', team_id: team.id.to_s, team_name: team.name)
  end

  def track_protip_view!(protip)
    track!('viewed protip', protip_id: protip.public_id, protip_score: protip.score)
  end

  def track_opportunity_view!(opportunity)
    track!('viewed opportunity', opportunity_id: opportunity.id, team: opportunity.team_id)
  end
end
