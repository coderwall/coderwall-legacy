Coderwall.ExpertEventView = Ember.View.extend(
  templateName: "events/expert"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["expertEvent"]

  expertEvent: Ember.computed(->
    classnames = ["cf"]
    switch @.event.event_type
      when 'new_mayor' then classnames.push "mayor"

    classnames.join(" ")
  ).property().cacheable()

)
