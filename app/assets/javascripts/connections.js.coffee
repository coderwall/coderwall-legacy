$ ->
  top = $("#network-header").offset().top - parseFloat($("#network-header").css("margin-top").replace(/auto/, 0))

  fixPositionNetworkHeader = ->
    console.log $(window).scrollTop()
    if $(window).scrollTop() >= top
      $("#network-header").addClass "fixed"
      $('a.back-up').fadeIn().removeClass 'hide'
    else
      $("#network-header").removeClass "fixed"
      $('a.back-up').addClass 'hide'

  $(window).scroll (event) ->
    fixPositionNetworkHeader()

  fixPositionNetworkHeader()