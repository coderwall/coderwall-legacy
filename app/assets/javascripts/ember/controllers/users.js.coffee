Coderwall.usersController = Ember.ResourceController.create(
  resourceType: Coderwall.User
  userStatusUrl: "/user/status"
  signedInUser: null

  init: ->
#      $.get(@.userStatusUrl).success (data)->
#        if data.any?
#          @.signedInUser = Coderwall.User.create(data)
)