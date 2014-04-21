Coderwall.ShowTeamView = Ember.View.extend(
  templateName: "ember/templates/teams/show"
  classNames: [ "team" ]
  tagName: "tr"

  follow: (e)->
    team = @get("team")
    team.follow()
    e.preventDefault()
)