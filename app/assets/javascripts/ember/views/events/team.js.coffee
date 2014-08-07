Coderwall.TeamEventView = Ember.View.extend(
  templateName: "events/team"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]

  showTeam: Ember.computed(->
    if @content.get('actionable') then "show follow track" else "hide"
  ).property('event.actionable').cacheable()

  followTeam: ->
    @content.set('actionable', false)

  protipEvent: Ember.computed(->
    classnames = ["new-team", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)
