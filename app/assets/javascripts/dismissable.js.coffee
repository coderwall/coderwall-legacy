#= require jquery-cookie

$ ->
  $('[data-dismissable]').each ->
    $el = $(@)
    key = "dismissed-#{$el.data('dismissable')}"

    if $.cookie(key) == "true"
      $el.hide()
      $('.tee-ribbon').css("top", "0px")
    else
      $el.fadeIn()
      $('.tee-ribbon').css("top", "40px")

    $('.js-dismiss', $el).click (e)->
      e.preventDefault()
      $.cookie(key, "true")
      $el.fadeOut()
      $('.tee-ribbon').css("top", "0px")
