Coderwall.AdminEventView = Ember.View.extend(
  templateName: "events/admin"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]

  protipEvent: Ember.computed(->
    classnames = ["admin", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)
