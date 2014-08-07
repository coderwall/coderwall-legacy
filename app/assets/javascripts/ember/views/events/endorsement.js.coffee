Coderwall.EndorsementEventView = Ember.View.extend(
  templateName: "events/endorsement"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["endorsementEvent"]

  endorsementEvent: Ember.computed(->
    classnames = ["endorsement", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)
