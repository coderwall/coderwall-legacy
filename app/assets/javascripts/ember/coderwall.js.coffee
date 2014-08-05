#= require      handlebars
#= require      ./ember
#= require      ./ember-rest
#= require      ./ember-routemanager
#= require      sorted-array
#= require_self

Ember.ENV.CP_DEFAULT_CACHEABLE = true

window.Coderwall = Ember.Application.create()

Coderwall.routeManager = Ember.RouteManager.create(
  protips: Ember.ViewState.create(
    route: "p/t"
    view: Coderwall.protipsView
    index: Ember.State.create(
      route: ":tag"
      enter: (stateManager, transition) ->
        @_super stateManager, transition
        params = stateManager.get("params")
        tags = params
        alert tags
    )
  )
)

Coderwall.displayError = (e) ->
  if typeof e is "string"
    alert e
  else if typeof e is "object" and e.responseText isnt `undefined`
    alert e.responseText
  else
    alert "An unexpected error occurred."