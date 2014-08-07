Coderwall.ViewEventView = Ember.View.extend(
  templateName: "events/view"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]

  protipEvent: Ember.computed(->
    classnames = ["cf"]
    switch @.event.event_type
      when 'protip_view' then classnames.push "protip-viewed"
      when 'profile_view' then classnames.push "profile-viewed"
      when 'protip_upvote' then classnames.push "protip-upvoted"

    classnames.join(" ")
  ).property().cacheable()

)
