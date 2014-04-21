$ ->
  $('.join, .member').on 'click', ->
    $(@).toggleClass('member')
    $(@).toggleClass('join')
    join_or_leave = if $(@).hasClass("join") then "join" else "leave"
    text = $(@).attr('data-properties')
    $(@).attr('data-action', join_or_leave + " " + text)
#    url = /(.+)(join|leave)/.exec($(@).attr('href'))[1]
#    $(@).attr('href', url+join_or_leave)

$(document).ajaxComplete (e, xhr, options)->
  handle_redirect(xhr)