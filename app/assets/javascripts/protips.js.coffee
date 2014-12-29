# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require  marked
#= require  highlight/highlight
#= require  highlight/language
#= require  blur
#= require  jquery.filedrop
#= require  jquery.textselection
#= require local_time

window.handle_redirect = (response)->
  window.location = response.to  if (response.status == "redirect")

$(window).load ->
  if $('#q').length > 0
    registerSearchHistoryHandler()

$ ->
  $(window).scroll ->
    if $(window).scrollTop() > 0
      $('.side-conversion-alert').fadeIn()

  initializeProtip()
  $('#x-protip-preview')
  $.ajaxPrefilter (options, originalOptions, jqXHR) ->
    originalSuccess = options.success
    options.success = (response) ->
      handle_redirect(response)
      originalSuccess response if originalSuccess?

  $('.submit-on-enter').keydown (event)->
    if event.keyCode == 13
      search(null)

  enablePreviewEditing()


window.initializeProtip = ->
  if inEditMode = $(".x-tip-content.preview").length > 0
    setTimeout (->
      animateFloat()), 100
    registerAutosaver()
    registerTextareaAutoResize()
    registerFlipper()
    enableDragNDrop()
    $('#protip_title').focus()
  else
    highlightCode() if hljs?

  $('input[name=authenticity_token]').val($('meta[name=csrf-token]').attr('content'))

  $('a.protip-subscription:not(.noauth)').on 'click', (e) ->
    subscription_link = $(@)
    action = subscription_link.attr('href')
    toggleSubscriptionStatus(subscription_link)
    $.ajax action,
      type: 'PUT'
      dataType: 'text'
      error: (jqXHR, textStatus, errorThrown) ->
        toggleSubscriptionStatus(subscription_link)
      success: (response) ->
        handle_redirect(response)

    e.preventDefault()
  markFollowings()
  registerToggles()
  enableSearchBox()
  registerMoreHistory()
  enableCommentReply()
  enableCommentLikeUpdate()
  enableCommentEditing()
  enableTabInTextbox()
  fixScrollBars()
  fillComment()
  setupMobileMenu()
  show_hide_by_current_user()

toggleSubscriptionStatus = (subscription_link) ->
#  subscription_link.toggleClass('protip-subscribe')
  subscription_link.toggleClass('subscribed')
  reverse_action = subscription_link.data('reverse-action')
  subscription_link.data('reverse-action', subscription_link.attr('href'))
  subscription_link.attr('href', reverse_action)


cardSides = $('.card .side')
viewingSide = 0
is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;

$.fn.vertical_float_to = (target)->
  if target
    @.animate({top: $(target).height() + $(target).offset().top + 25})

animateFloat = (delay)->
  target = cardSides[viewingSide]
  #if the element will be in the middle of the card, don't show it. animate it hidden
  if ($(target).outerHeight() + $(target).offset().top) > $('.vertical-floatable').offset().top
    $('.vertical-floatable').hide()
  setTimeout (->
    verticalFloat()), delay

verticalFloat = ->
  $('.vertical-floatable').vertical_float_to(cardSides[viewingSide])
  setTimeout (->
    $('.vertical-floatable').show()), 400

registerFlipper = ->
  $('.back.side').addClass('faded') if is_chrome
  $(document).keydown (event)->
    if ((event.keyCode == 38) or (event.keyCode == 40)) and (event.ctrlKey or event.metaKey)
      flipCard()

  $('.preview-button').bind 'click', (event)->
    event.preventDefault()
    flipCard()

flipCard = ->
  if($(".card").hasClass('rotated'))
    flip()
  else
    fetchPreview()

preview = (html)->
  $('#x-protip-preview').html(html)
  flip()

flip = ->
  $(cardSides[viewingSide]).toggleClass("faded") if is_chrome
  viewingSide = (viewingSide + 1) % cardSides.length
  $(cardSides[viewingSide]).toggleClass("faded") if is_chrome
  card = $(".card")
  card.toggleClass "rotated"
  $('.tip-panel').height($('.tip-panel').parent().outerHeight())
  animateFloat(500)

fetchPreview = ->
  title = $('#protip_title').val()
  body = $('#protip_body').val()
  topics = $('#protip_tags').val()

  $.ajax '/p/preview',
    type: 'POST'
    data:
      protip:
        title: title
        body: body
        topics: topics
    success: (data, status, xhr) ->
      preview(data)

registerAutosaver = ->
  window.protip_auto_saver = new Coderwall.Autosaver.TextField({field_id: "protip_body", key_append: window.current_user})
  $("#protip-save-and-publish-button").on "click" , ()->
    window.protip_auto_saver.clear()

registerTextareaAutoResize = ->
  $("textarea").keydown (event) ->
    if event.keycode == 13
      scaleTextareas()
  $("textarea").bind 'paste, input, focus', ->
    scaleTextareas()

scaleTextareas = ->
  $("textarea").each (i, t) ->
    newHeight = t.scrollHeight
    currentHeight = t.clientHeight
    textarea_lineheight = 3
    if newHeight > currentHeight
      t.style.height = newHeight + 5 * textarea_lineheight + 'px'
      animateFloat(50)

  setTimeout scaleTextareas, 1000

enableDragNDrop = ->
  html5enabled = (window.File && window.FileReader && window.FileList && window.Blob) != undefined
  fileinput = $('#dropzone input[type=file].safari5-upload-hack')
  dropzone = $('#dropzone')
  dropzone.filedrop
    maxfiles: 5
    maxfilesize: 2
    paramname: 'picture'
    headers:
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      "Accept": "text/javascript"
    url: $('#dropzone').attr('data-picture-upload-path')
    shouldupload: html5enabled
    input_element: if html5enabled then null else fileinput
    dragOver: ->
      dragOver()
    dragLeave: ->
      dragLeave()
    uploadStarted: (i, file, len)->
      uploadStarted(i, file, len)
    uploadFinished: (i, file, response, time)->
      uploadFinished(i, file, response, time)


dragOver = ->
  $("#dropzone").addClass 'upload-ready'

dragLeave = ->
  $("#dropzone").removeClass 'upload-ready'

uploadStarted = (i, file, len)->
  $("#dropzone").removeClass 'upload-ready'
  $("#dropzone").addClass 'upload-in-progress'

uploadFinished = (i, file, response, time)->
  markdown = '![Picture](' + response.file.url + ')'
  $('#protip_body').val $('#protip_body').val() + markdown
  $("#dropzone").removeClass 'upload-in-progress'

getFollowings = (type)->
  $('#x-following-' + type.toLowerCase()).data(type.toLowerCase())

markFollowings = ->
  $(follow).addClass('followed') for follow in $('.x-protip-pane .follow') when follow.attributes['data-value'].value in getFollowings($(follow).data('follow-type'))

window.registerToggles = ->
  $('.upvote,.small-upvote').on 'click', ->
    if $(@).not('.upvoted').length == 1
      $(@).html(((Number) $(@).html()) + 1)
    $(@).addClass('upvoted')
  $('.flag').on 'click', ->
    $(@).toggleClass('flagged')
  $('.user-flag').on 'click', ->
    $(@).addClass('user-flagged')
  $('.feature').on 'click', ->
    $(@).toggleClass('featured')
  $('.like').on 'click', ->
    $(@).addClass('liked')
    $(@).removeClass('not-liked')
  $('.follow').on 'click', (e)->
    unless $(e.target).data('follow-type') == 'Network'
      $(e.target).toggleClass('followed')

enableSearchBox = ->
  $('.slidedown').on 'click', (e)->
    target = $('#' + $(@).data('target'))
    target.animate({opacity: "toggle"})
    target.find('input[type=text]').first().focus()
    e.preventDefault()

  $('.slideup').on 'click', (e)->
    $('#' + $(@).data('target')).animate({opacity: "toggle"})
    clearSearchUrlHistory()
    e.preventDefault()

samepage = false
registerSearchHistoryHandler = ->
#  History.Adapter.bind window, 'statechange', ->
  $(window).bind 'popstate', ->
    state = History.getState()
    unless ($.isEmptyObject(state.data) || samepage)
      search(state.data)
      $('.slidedown').trigger('click')


window.recordSearchUrlInHistory = (params = null)->
  unless params?
    params = {q: $('#q').val()}
  if !$.isEmptyObject(params['q'])
    samepage = true
    History.replaceState(params, "Search results")

clearSearchUrlHistory = ->
  History.replaceState(null, window.location.title)

search = (params)->
  form = $('#q').closest('form')
  for k,v of params
    if k == 'q'
      $('#q').val(v)
    else
      appendSearchOptions(k, v, form)

  $('#q').trigger("submit")
  recordSearchUrlInHistory()

appendSearchOptions = (name, value, element) ->
  $('<input>').attr('type', 'hidden').attr('name', name).val(value).appendTo(element)

enableTabInTextbox = ->
  $('#protip_body,#comment_comment').keydown (event)->
    if event.keyCode == 9 #tab
      selection = $(@).getSelectedText()
      unless $.isEmptyObject(selection)
        $(@).replaceSelectedText(spaceText(selection, 4), false)
        event.preventDefault()

spaceText = (text, num_spaces)->
  spaces = ""
  spaces += " " for n in [1..num_spaces]
  spaces + text.split("\n").join("\n" + spaces)

fixScrollBars = ->
  $('code').each(->
    if($(this).outerHeight() < 300)
      $(this).css('overflow-y', 'hidden')
  )

fillComment = ->
  pending_comment = getParameterByName('comment')
  new_comment = $('.add-comment #comment_comment')
  new_comment.val(pending_comment) if new_comment.length != 0 && new_comment.val().length == 0 && pending_comment?

setupMobileMenu = ->
  $('#x-mobile-menu').slideToggle()
  $('#x-mobile-toggle').on 'click', ->
    $('#x-mobile-menu').slideToggle()

getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))

onpage = false
window.registerMoreHistory = ->
#  $('#more > a').on 'click', ->
#    onpage = true
#    History.replaceState(null, window.location.title, $(@).attr('href'))
#    History.Adapter.bind(window,'statechange', ->
#      unless onpage
#        state = History.getState()
#        window.location.href = state.url
#
#    )

window.highlightCode = ->
  hljs.initHighlighting()

enableCommentReply = ->
  $('.reply').on 'click', ->
    username = $(this).closest('li.cf').find('a.comment-user').attr('data-reply-to')
    textbox = $('#add-comment textarea')
    textbox.text("@" + username + " ")
    textbox.setSelectionRange(textbox.val().length)

enableCommentLikeUpdate = ->
  $('.like').one 'click', ->
    count = (Number) $(this).text()
    count += 1
    $(this).text(count)

enableCommentEditing = ->
  $('a.edit, .edit-comment .button').on 'click', ->
    comment = $(this).closest('li.cf').find('.comment')
    toggleCommentEditMode(comment)

toggleCommentEditMode = (comment)->
  comment.children('p').first().toggleClass('hidden')
  comment.find('.edit-comment').toggleClass('hidden')
  comment.siblings('ul.edit-del').toggleClass('hidden')

marked.setOptions highlight: (code) ->
  hljs.highlightAuto(code).value

enablePreviewEditing = ->
  if $('.preview-body').length > 0
    updatePreview = ->
      markdown = marked $('#protip_body').val(), gfm: true
      $('.preview-body').html markdown

    $('#protip_body').on 'keyup', updatePreview

    updatePreview()