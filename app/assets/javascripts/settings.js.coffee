$ ->
  showProfileSection = (navigationElement) ->
    $("a.filternav").removeClass "active"
    navigationElement.addClass "active"
    $(".editsection").hide()
    $(navigationElement.attr("href") + "_section").fadeIn()

  $("a.filternav").click (e) ->
    showProfileSection $(this)

  $('a[href=#jobs]').click (e) ->
    $('#pb').show();
  $('a.filternav:not(a[href=#jobs])').click (e) ->
    $('#pb').hide();

  unless window.location.hash is ""
    preSelectedNavigationElement = $("a.filternav[href=\"" + window.location.hash + "\"]")
    showProfileSection preSelectedNavigationElement

  Chute.setApp('502d8ffd3f59d8200c000097')
  $("a.photo-chooser").click (e)->
    e.preventDefault()
    width = $(@).attr("data-fit-w")
    height = $(@).attr("data-fit-h")
    input = $('#' + $(@).attr("data-input"))
    preview = $(@).parents('.preview')
    Chute.MediaChooser.choose #https://github.com/chute/media-chooser    
      limit: 1,
      (urls, data)->
        url = urls[0]
        url = Chute.fit(width, height, url)
        input.val(url)
        preview.children('img').remove()
        preview.prepend("<img src='" + url + "'/>")
