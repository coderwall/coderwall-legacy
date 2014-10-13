window.ProtipRouter = Backbone.Router.extend(
  routes:
    'p/:id': 'fetchProtip'
    '*path': 'closeProtip'

  fetchProtip: (id)->
      $.ajax '/p/' + id,
        type: 'GET'
        data:
          mode: 'popup'
        dataType: 'script'

  closeProtip: ->
    $('#x-active-preview-pane').remove()
)
