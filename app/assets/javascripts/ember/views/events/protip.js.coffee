Coderwall.ProtipEventView = Ember.View.extend(
  templateName: "events/protip"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]

  protipEvent: Ember.computed(->
    classnames = ["ptip", "cf"]
    switch @.event.event_type
      when 'new_protip'
        if @.event.kind == "link" then classnames.push "link-protip" else classnames.push "new-protip"
      when 'trending_protip' then classnames.push "trending-protip"
    classnames.join(" ")
  ).property().cacheable()

  didInsertElement: ->
    registerToggles()
)
