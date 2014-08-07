Coderwall.SkillEventView = Ember.View.extend(
  templateName: "events/skill"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["protipEvent"]
  skillsBinding: 'Coderwall.activityFeedController.skills'

  showSkill: Ember.computed(->
    if @content.skill.name in Coderwall.activityFeedController.skills then "hide" else "show add-skill track"
  ).property('event.actionable').cacheable()

  addSkill: ->
    Coderwall.activityFeedController.skillAdded(@content.skill.name)
    @content.set('actionable', false)

  protipEvent: Ember.computed(->
    classnames = ["added-skill", "cf"]
    classnames.join(" ")
  ).property().cacheable()

)
