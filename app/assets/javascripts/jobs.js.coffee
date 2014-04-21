$ ->
  $('a.filter').on 'click', (e)->
    $('.location-drop-down').toggleClass("hide")
    e.stopPropagation()

  $(document).on 'click', ->
    $('.location-drop-down').addClass("hide")

