Coderwall.teamsController = Ember.ResourceController.create(
  resourceType: Coderwall.Team
  followedTeamsList: null

  updateFollowedTeam: (team_id)->
    @followedTeamsList[team_id] = !@followedTeamsList[team_id]
)

