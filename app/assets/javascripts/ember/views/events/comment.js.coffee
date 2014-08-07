Coderwall.CommentEventView = Ember.View.extend(
  templateName: "events/comment"
  eventBinding: 'content'
  tagName: "li"
  classNameBindings: ["commentEvent"]

  commentEvent: Ember.computed(->
    classnames = ["comment", "cf"]
    switch @.event.event_type
      when 'comment_like' then classnames.push "comment-liked"
      else
        classnames.push "comment"
    classnames.join(" ")
  ).property().cacheable()

  didInsertElement: ->
    registerToggles()
)
