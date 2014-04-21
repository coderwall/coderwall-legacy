Coderwall.AdminEventView = Ember.View.extend(
  templateName: "ember/templates/events/admin"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]

  protipEvent: Ember.computed(->
    classnames = ["admin", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)