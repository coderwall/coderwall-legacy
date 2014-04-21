Coderwall.Event = Ember.Resource.extend(
  resourceUrl: "/:username/events"
  resourceName: "event"
  resourceProperties: [ "version", "event_type", "tags", "url", "hiring" ]
  actionable: true

  tweetUrl: Ember.computed(->
    correctedUrl = encodeURI(@.url)
    unless /^https?::\/\//.test(correctedUrl)
      correctedUrl = "http://coderwall.com" + correctedUrl
    'http://twitter.com/share?url=' + correctedUrl + '&via=coderwall&text=' + encodeURI(@.title) + '+%23protip&related=&count=vertical&lang=en'
  ).property().cacheable()

  teamHireUrl: Ember.computed(->
    @team.url + "#open-positions"
  ).property('url').cacheable()

  topTag: Ember.computed(->
    if @.tags.get('firstObject')? then @.tags.get('firstObject') else null
  ).property().cacheable()

  belongsToTeam: Ember.computed(->
    if @.team? then true else false
  ).property().cacheable()

  protipEvent: Ember.computed(->
    @event_type == 'protip_view' or @event_type == 'protip_upvote'
  ).property('event_type').cacheable()

  viewEvent: Ember.computed(->
    @event_type == 'protip_view' or @event_type == 'profile_view'
  ).property('event_type').cacheable()


  eventTypeString: Ember.computed(->
    switch @.event_type
      when 'new_protip' then 'New protip'
      when 'trending_protip' then 'Trending protip'
      when 'admin_message' then 'A message from Coderwall'
      when 'new_team' then 'created a new team'
      when 'new_skill' then 'added a skill'
      when 'endorsement' then 'endorsed you'
      when 'unlocked_achievement' then 'just unlocked an achievement'
      when 'profile_view' then 'viewed your profile'
      when 'protip_view' then 'viewed your protip'
      when 'protip_upvote' then 'upvoted your protip'
      when 'followed_team' then 'just followed your team'
      when 'followed_user' then 'just followed you'
      when 'new_mayor' then 'is mayor of'
      when 'new_comment' then 'commented on your protip'
      when 'comment_like' then 'liked your comment'
      when 'comment_reply' then 'replied to your comment'
  )
)