#= require highlight/highlight
#= require highlight/language
#= require backbone/routers/ProtipRouter
#= require backbone/views/ProtipGridView
#= require protips
$ ->
  Backbone.history.start({pushState: true})
  history.pushState(null, null, window.location.href)
  Backbone.history.push
  window.protipRouter = new ProtipRouter()
  window.protipGrid = new ProtipGridView(protipRouter)

window.registerProtipClickOff = ->
  $('html').on 'click', (e)->
    activePane = $('#x-active-preview-pane')
    #contains works on dom elements not jquery
    content = activePane.find('.x-protip-content')
    if((activePane.length > 0) && (content.length > 0) && !$.contains(content[0], e.target))
      activePane.fadeTo('fast', 0)
      activePane.remove()
      window.history.back()
