window.ProtipView = Backbone.View.extend(

  el: $("#x-protip")

  events:
    "click .upvote,.small-upvote": "upvote"
    "click .flag": "flag"
    "click .user-flag": "user_flag"
    "click .feature": "feature"
    "click .like": "like"

  initialize: ->
    this.highlightCode() if hljs?
    this.enableCommentReply()
    this.enableCommentLikeUpdate()
    this.enableCommentEditing()
    this.render()

  highlightCode: ->
    hljs.initHighlighting()

  upvote: ->
    $('.upvote,.small-upvote').on 'click', ->
      if $(@).not('.upvoted').length == 1
        $(@).html(((Number) $(@).html()) + 1)
      $(@).addClass('upvoted')

  flag: (e)->
    $(e.target).toggleClass('flagged')

  user_flag: (e)->
    $(e.target).addClass('user-flagged')

  feature: ->
    $(@).toggleClass('featured')

  like: ->
    $(@).addClass('liked')
    $(@).removeClass('not-liked')


  enableCommentReply: ->
    $('.reply').on 'click', ->
      username = $(this).closest('li.cf').find('a.comment-user').attr('data-reply-to')
      textbox = $('#add-comment textarea')
      textbox.text("@" + username + " ")
      textbox.setSelectionRange(textbox.val().length)

  enableCommentLikeUpdate: ->
    $('.like').one 'click', ->
      count = (Number) $(this).text()
      count += 1
      $(this).text(count)

  enableCommentEditing: ->
    $('a.edit, .edit-comment .button').on 'click', ->
      comment = $(this).closest('li.cf').find('.comment')
      toggleCommentEditMode(comment)

  toggleCommentEditMode: (comment)->
    comment.children('p').first().toggleClass('hidden')
    comment.find('.edit-comment').toggleClass('hidden')
    comment.siblings('ul.edit-del').toggleClass('hidden')

)
