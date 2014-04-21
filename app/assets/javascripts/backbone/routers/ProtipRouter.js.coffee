window.ProtipRouter = Backbone.Router.extend(
  routes:
    'p/:id': 'fetchProtip'
    '*path': 'closeProtip'

  fetchProtip: (id)->
    if(id.match(/^[\dA-Z\-_]{6}$/i))
      $.ajax '/p/' + id,
        type: 'GET'
        data:
          mode: 'popup'
        dataType: 'script'
    else
      @.closeProtip()

  closeProtip: ->
    $('#x-active-preview-pane').remove()
)
