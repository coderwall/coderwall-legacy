Coderwall.ListTeamsView = Ember.View.extend(
  templateName: "teams/index"
  teamsBinding: "Coderwall.teamsController"

  refreshListing: ->
    Coderwall.teamsController.findAll()
)
