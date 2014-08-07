Coderwall.ShowTeamView = Ember.View.extend(
  templateName: "teams/show"
  classNames: [ "team" ]
  tagName: "tr"

  follow: (e)->
    team = @get("team")
    team.follow()
    e.preventDefault()
)
