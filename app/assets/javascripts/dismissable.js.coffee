#= require jquery-cookie

$ ->
  $('[data-dismissable]').each ->
    $el = $(@)
    key = "dismissed-#{$el.data('dismissable')}"

    if $.cookie(key) == "true"
      $el.hide()
    else
      $el.fadeIn()

    $('.js-dismiss', $el).click (e)->
      e.preventDefault()
      $.cookie(key, "true")
      $el.fadeOut()
