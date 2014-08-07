Coderwall.FollowEventView = Ember.View.extend(
  templateName: "events/follow"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["followEvent"]

  followEvent: Ember.computed(->
    classnames = ["cf"]
    if @.event.event_type == "followed_team" then classnames.push "new-team-follow" else classnames.push "new-follow"
    classnames.join(" ")
  ).property().cacheable()

)
