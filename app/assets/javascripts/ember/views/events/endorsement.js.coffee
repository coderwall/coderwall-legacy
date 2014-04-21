Coderwall.EndorsementEventView = Ember.View.extend(
  templateName: "ember/templates/events/endorsement"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["endorsementEvent"]

  endorsementEvent: Ember.computed(->
    classnames = ["endorsement", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)