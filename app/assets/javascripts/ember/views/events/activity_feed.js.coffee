Coderwall.ActivityListView = Ember.CollectionView.create(
#  templateName: "ember/templates/events/activity_list"
  contentBinding: "Coderwall.activityFeedController.activities"
  tagName: "ul"
  createChildView: (view, attrs) ->
    console.log("attempting to render " + attrs.content)

    switch attrs.content.event_type
      when 'new_protip' then view = Coderwall.ProtipEventView
      when 'trending_protip' then view = Coderwall.ProtipEventView
      when 'admin_message' then view = Coderwall.AdminEventView
      when 'new_team' then view = Coderwall.TeamEventView
      when 'new_skill' then view = Coderwall.SkillEventView
      when 'endorsement' then view = Coderwall.EndorsementEventView
      when 'unlocked_achievement' then view = Coderwall.AchievementEventView
      when 'profile_view' then view = Coderwall.ViewEventView
      when 'protip_view' then view = Coderwall.ViewEventView
      when 'protip_upvote' then view = Coderwall.ViewEventView
      when 'followed_user' then view = Coderwall.FollowEventView
      when 'followed_team' then view = Coderwall.FollowEventView
      when 'new_mayor' then view = Coderwall.ExpertEventView
      when 'new_comment' then view = Coderwall.CommentEventView
      when 'comment_like' then view = Coderwall.CommentEventView
      when 'comment_reply' then view = Coderwall.CommentEventView
      else
        view = Coderwall.AdminEventView

    @._super(view, attrs)

  didInsertElement: ->
    #calling all the global functions that are necessary for rewiring rendered events to the rest of the site
    registerToggles()
    @._super()

)

Coderwall.MoreActivityView = Ember.View.create(
  #templateName: "ember/templates/events/more_activity"
  classNameBindings: ["visibility"]
  tagName: "li"

  visibility: Ember.computed(->
    classes = "more-activity cf"
    console.log("changing visibility " + Coderwall.activityFeedController.unreadActivities.length)
    if Coderwall.activityFeedController.unreadActivities.length > 0 then classes else (classes + " no-new-activity")
  ).property('Coderwall.activityFeedController.unreadActivities.@each').cacheable()

  showUnreadActivity: ->
    console.log("showing unread activity")
    Coderwall.activityFeedController.releaseUnreadActivities(true)
)

Coderwall.ActivityFeedView = Ember.ContainerView.create(
  classNames: ["feed"]
  tagName: "ul"
  childViews: ["unreadActivityView", "activityListView", "previousActivityView"]
  unreadActivityView: Coderwall.MoreActivityView
  activityListView: Coderwall.ActivityListView
  previousActivityView: Coderwall.MoreActivityView
)

Coderwall.ActivityStatsView = Ember.View.create(
  #templateName: "ember/templates/events/stats"
  tagName: "ul"
  profileViewsBinding: "Coderwall.statsController.profileViews"
  followersBinding: "Coderwall.statsController.followers"
  protipsBinding: "Coderwall.statsController.protips"
  protipUpvotesBinding: "Coderwall.statsController.protipUpvotes"

)
#$ ->
Coderwall.ActivityFeedView.appendTo('#activity_feed')
Coderwall.ActivityStatsView.appendTo('#stats')
