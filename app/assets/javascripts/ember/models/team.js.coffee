Coderwall.Team = Ember.Resource.extend(
  resourceUrl: "/teams"
  resourceName: "team"
  resourceProperties: [ "id", "name", "rank", "score", "size", "avatar", "country", "team_url", "follow_path",
                        "followed" ]

  rounded_score: Ember.computed(->
    Math.round(@get("score"))
  ).property("score").cacheable()

  ordinalized_rank: Ember.computed(->
    @get("rank").toString().ordinalize()
  ).property("score", "rank").cacheable()

  has_more_than_min_members: Ember.computed(->
    @get("size") > 3
  ).property("size").cacheable()

  remaining_members: Ember.computed(->
    @get("size") - 3
  ).property("size").cacheable()

  follow_text: Ember.computed(->
    if @get("followed")
      "Unfollow"
    else
      "Follow"
  ).property("followed").cacheable()

#    followed: Ember.computed(->
#      Coderwall.teamsController.followedTeamsList[@get("id")]
#    ).property().cacheable()

  follow: ->
    team = @
    $.post(this.follow_path).success ->
      Coderwall.teamsController.updateFollowedTeam team.get("id")
      team.set("followed", Coderwall.teamsController.followedTeamsList[team.get("id")])

  followed_class: Ember.computed(->
    classes = "btn btn-large follow "
    if @get("followed")
      classes += "btn-primary"
    classes
  ).property("followed").cacheable()

)