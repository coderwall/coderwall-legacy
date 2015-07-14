module UserTeam
  extend ActiveSupport::Concern

  def team
    if team_id
      Team.find(team_id)
    else
      membership.try(:team)
    end
  end

  def team_member_ids
    User.where(team_id: self.team_id.to_s).pluck(:id)
  end

  def on_team?
    team_id.present? || membership.present?
  end

  def team_member_of?(user)
    on_team? && self.team_id == user.team_id
  end

  def on_premium_team?
    if membership
      membership.team.premium?
    else
      false
    end
  end

  def belongs_to_team?(team)
    team.member_accounts.pluck(:id).include?(id)
  end

end

