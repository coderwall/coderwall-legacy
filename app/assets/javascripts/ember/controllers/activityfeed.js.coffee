#= require history.adapter.jquery
#= require history

Coderwall.activityFeedController = Ember.ArrayController.create(
  resourceType: Coderwall.Event
  requestInterval: 60 * 1000
  rateLimitInterval: 60 * 60 * 1000
  subscribedChannels: []
  reloadTimer: null
  username: null
  unreadActivities: []
  activities: []
  sortedActivities: []
  content: []
  skills: []
  skillsShown: []
  achievements: []
  achievementsShown: []
  inputCollectionName: "activities"
  outputCollectionName: "sortedActivities"
  sortOrder: "normal"
  maxCollectionSize: 100
  rateLimitTable: {
    new_skill:
      limit: 15
      count: 0
    unlocked_achievement:
      limit: 10
      count: 0
  }
  viewingSince: 0
  updating: false
  lastPull: new Date()
  profileUrl: null
  protipsUrl: null
  connectionsUrl: null

  skillAdded: (skill_name)->
    @skills.push(skill_name)

  sortFunction: (eventA, eventB)->
    eventB.timestamp - eventA.timestamp

  unreadActivityCount: Ember.computed(->
    @.get('unreadActivities').size
  ).property('unreadActivities').cacheable()

  loadSubscriptions: (channels)->
    @.set('subscribedChannels', channels)

  resourceUrl: Ember.computed(->
    return @.get("username") + "/events/more"
  ).property("username").cacheable()

  start: ->
    @set('viewingSince', (new Date()).valueOf() / 1000)
    context = @
    #    @resetRateLimits()
    @.subscribeToChannels()
    @.startRequestTimer()
    #    @.startRateLimitTimer()
    window.onfocus = ->
      context.userPresence(true)
    window.onblur = ->
      context.userPresence(false)

  subscribeToChannels: ->
    @.subscribeToChannel(channel) for channel in @.get('subscribedChannels')

  subscribeToChannel: (channel_name)->
    context = @
    console.log("subscribing to " + channel_name)
    PUBNUB.subscribe({channel: channel_name}, (message)->
      context.processChannelData(channel_name, message))

  processChannelData: (channel_name, data) ->
    console.log("received data from " + channel_name + ", data:" + data.toString())
    event = $.parseJSON(data)
    @.addEvent(event) if event?

  loadEvents: (events) ->
#    events = $.parseJSON(data)
    @.addEvent(event) for event in events

#  loadFromHistory: ->
#    context = @
#    remainingChannels = @.subscribedChannels.length
#    console.log("requesting history from " + remainingChannels + " channels")
#    (PUBNUB.history({channel: subscribedChannel, limit: 50},
#    (messages) ->
#      console.log("got " + messages.length + " messages from history on channel " + subscribedChannel)
#      context.processChannelData(subscribedChannel, message) for message in messages
#      remainingChannels -= 1
#      if remainingChannels == 0
#        context.releaseUnreadActivities(true)
#
#    ); console.log("requested history from " + subscribedChannel)) for subscribedChannel in @.subscribedChannels

  addEvent: (event_data) ->
    event = Coderwall.Event.create(event_data)
    console.log("pushing event " + event.event_type + " to content")
    @content.pushObject(event)

  requestMore: (->
    console.log("requesting more data from " + window.location.origin + "/" + @.get('resourceUrl'))
    context = @

    $.ajax({
      url: window.location.protocol + "//" + window.location.host + "/" + @.get('resourceUrl')
      dataType: 'json'
      data:
        since: context.viewingSince
        count: Math.floor(Math.random() * 10) + 1
      success: (stats)->
        context.set('viewingSince', (new Date()).valueOf() / 1000);
        context.updateStats(stats);
        context.startRequestTimer()
        })
  ).observes('window.onfocus')

  updateStats: (data)->
    stats = $.parseJSON(data)
    Coderwall.statsController.set('profileViews', data['profile_views'])
    Coderwall.statsController.set('protips', data['protips_count'])
    Coderwall.statsController.set('protipUpvotes', data['protip_upvotes'])
    Coderwall.statsController.set('followers', data['followers'])

  processEvents: (->
    if @.content.length > 0
      console.log("processing events")
      @.unreadActivities.pushObjects(event for event in @.content when !@duplicateEvent(event))
      #      @replaceBrowserState() if @.unreadActivities.length > 0
      @.content.clear()
  ).observes('content.@each')

  duplicateEvent: (event)->
    if event.user? and (event.user.username == @username)
      return true

    if event.event_type == 'new_skill'
      if (event.skill.name in @skillsShown)
        return true
      else
        @skillsShown.pushObject(event.skill.name)
        if (event.skill.name in @skills)
          return true
    else if event.achievement?
      if (event.achievement.name in @achievementsShown)
        return true
      else
        @achievementsShown.pushObject(event.achievement.name)
        if (event.achievement.name in @achievements)
          return true

    return @rateLimit(event)

  rateLimit: (event)->
    return false
#    rate = @rateLimitTable[event.event_type]
#    return false unless rate?
#    rate['count']++
#    rate['count'] > rate['limit']

  userPresence: (present)->
    console.log(((new Date()).valueOf() - @lastPull))
    if present and (((new Date()).valueOf() - @lastPull) > 60 * 1000) then @requestMore() else @stopRequestTimer()

  startRequestTimer: (->
    context = @
    @set('reloadTimer', setTimeout ->
      context.requestMore()
    , @get('requestInterval'))
  ).observes('window.onfocus')

  stopRequestTimer: (->
    console.log("Timer stopped")
    clearTimeout @get('reloadTimer')
  ).observes('window.onblur')

#  startRateLimitTimer: (->
#    console.log("Rate Limit Timer started")
#    context = @
#    @set('rateLimitTimer', setTimeout ->
#      context.resetRateLimits()
#    , @get('rateLimitInterval'))
#  )
#
#  resetRateLimits: ->
#    console.log("clearing rate limit table")
#    @rateLimitTable[event_type]['count'] = 0 for event_type, rate of @rateLimitTable

  releaseUnreadActivities: (pushState)->
    console.log("releasing activities ")
    @.activities.unshiftObjects(@.unreadActivities)
    @.unreadActivities.clear()
#    if pushState
#      @replaceBrowserState()

#  replaceBrowserState: (->
#    console.log("updating browser history")
#    @.set('updating', true)
#    if @.activities.length > 0
#      @set('lastPull', (new Date()).valueOf())
#      History.replaceState({lastPull: @lastPull, events: @.activities, unreadEvents: @.unreadActivities}, "activities", location.href)
#  )

#  handlePopState: ->
#    return if @get('updating')
#
#    unless History? and (state = History.getState())? and !$.isEmptyObject(state.data) and state.data.events? and state.data.events.length > 0 and ((new Date()).valueOf() - state.data.lastPull) < 5*60*1000
#      @loadFromHistory()
#    else
#      console.log("loading events from browser history")
#      @addEvent(event) for event in state.data.events
#      @releaseUnreadActivities(false)
#      @set('unreadActivities', state.data.unreadEvents)
#    @set('updating', false)
)

Coderwall.statsController = Ember.ResourceController.create(
  profileViews: null
  followers: null
  protips: null
  protipUpvotes: null
  profileUrl: null
  protipsUrl: null
)

#window.onpopstate =->
#  Coderwall.activityFeedController.handlePopState()

