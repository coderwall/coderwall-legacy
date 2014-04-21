Coderwall.ListTeamsView = Ember.View.extend(
  templateName: "ember/templates/teams/index"
  teamsBinding: "Coderwall.teamsController"

  refreshListing: ->
    Coderwall.teamsController.findAll()
)