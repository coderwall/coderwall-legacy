window.ProtipGridView = Backbone.View.extend(

  el: $("#x-protips-grid")

  events:
    "click #x-scope-toggle": "toggleScope"
    "click #x-followings-toggle": "toggleFollowings"
    "submit #x-search form": "search"
    "click #x-show-search": "showSearchBar"
    "click #x-hide-search": "hideSearchBar"
    "click #x-followings .unfollow": "removeUnfollowed"
    "click .x-mode-popup": "previewProtip"
    "click #x-active-preview-pane .follow": "updateFollowList"

  initialize: (router)->
    view = this
    this.render()
    $(document).ajaxComplete (e, xhr, options)->
      try handle_redirect(JSON.parse(xhr.responseText))
      catch Error
    this.markUpvotes()
    this.router = router
    this.loadFollowings()

  toggleScope: (e)->
    e.preventDefault()
    $(e.target).toggleClass('following').toggleClass('everything')
    this.search(e)

  toggleFollowings: (e)->
    e.preventDefault()
    $('#x-followings').slideToggle(400)

  showSearchBar: (e)->
    e.preventDefault()
    $('#x-scopes-bar').slideUp(100)
    $('#x-search').slideDown(600)
    $('#x-search input[type=text]').focus()

  hideSearchBar: (e)->
    e.preventDefault()
    $('#x-scopes-bar').slideDown(400)
    $('#x-search').slideUp(100)
    $('#x-scope-toggle').hide()

  search: (e)->
    e.preventDefault()
    query_string = $('#x-search form input[type=text]').val()
    query_string = null if query_string == $('#x-search form input[type=text]').attr('placeholder')

    domain = $('#x-search form') if query_string?
    domain = $('#x-scopes a.selected') unless domain?
    url = domain.attr('href')
    scope = if $('#x-scope-toggle').hasClass('following') then 'following' else 'everything'

    params = $.extend(this.parseUrl(url),
      scope: scope,
      search: query_string if query_string?
    )

    destination_url = url.split("?")[0] + "?" + $.param(params)
    window.location = destination_url

  parseUrl: (url = location.href) ->
    params = {}
    ( ( parts = part.split("=") ) && params[ parts[0] ] = parts[1] for part in ( url.split "?" ).pop().split "&" if url.indexOf("?") != -1 ) && params || {}

  markUpvotes: ->
    upvoted_protips = $('#upvoted-protips').data('protips')
    protips = $('.protip')
    this.highlightUpvote(protip) for protip in upvoted_protips if upvoted_protips?

  highlightUpvote: (protip)->
    $('#' + protip + ' .upvotes').addClass('upvoted')

  removeUnfollowed: (e)->
    li = $(e.target).closest('li')
    counter = li.parent().find('.x-follow-count')
    li.remove()
    counter.text(((Number) counter.text()) - 1)

  previewProtip: (e)->
    e.preventDefault()
    e.stopPropagation()
    protipId = $(e.currentTarget).closest('article').attr('id')
    this.router.navigate('/p/' + protipId, {trigger: true})
    this.dimLights()

  dimLights: ->
    pane = $("<div id='x-active-preview-pane' style='opacity:0'></div>")
    $("<div  class='dark-screen'></div>").appendTo(pane)
    $(this.el).append(pane)
    pane.fadeTo('slow', 1)
    $(window).scrollTop(pane.position().top)

  loadFollowings: ->
    this.followingNetworks = $('#x-following-networks').data('networks')
    this.followingUsers = $('#x-following-users').data('users')
    this.followingTeams = $('#x-following-teams').data('teams')

  updateFollowList: (e)->
    list = eval('this.following' + $(e.target).data('follow-type'))
    entity = $(e.target).data('value')
    if $(e.target).hasClass('followed') then (list.filter (val) ->
      val is entity)
    else
      list.push entity

)