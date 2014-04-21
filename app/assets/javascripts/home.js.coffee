#= require jquery.flexslider-min.js

$ ->
  displayNext = (selector, css_class) ->
    visibleUser = $(selector).not(".hide")
    if visibleUser.length <= 0
      $(selector).first(css_class).removeClass "hide"
    else
      visibleUser.addClass "hide"
      next = visibleUser.next(css_class)
      if next.length <= 0
        $(selector).first(css_class).removeClass "hide"
      else
        next.removeClass "hide"

    repeat = ->
      displayNext selector, css_class

    setTimeout repeat, 6000


  displayNext "#connect ul.users li.developers", ".developers"
  displayNext "#connect ul.users li.entrepreneurs", ".entrepreneurs"
  displayNext "#connect ul.users li.designers", ".designers"

  $('section.slider').flexslider()