$(document).ready ->
  filterPath = (string) ->
    string.replace(/^\//, "").replace(/(index|default).[a-zA-Z]{3,4}$/, "").replace /\/$/, ""
  scrollableElement = (els) ->
    i = 0
    argLength = arguments.length

    while i < argLength
      el = arguments[i]
      $scrollElement = $(el)
      if $scrollElement.scrollTop() > 0
        return el
      else
        $scrollElement.scrollTop 1
        isScrollable = $scrollElement.scrollTop() > 0
        $scrollElement.scrollTop 0
        return el  if isScrollable
      i++
    []
  locationPath = filterPath(location.pathname)
  scrollElem = scrollableElement("html", "body")

  scrollToElement = (target, targetOffset) ->
    customOffset = $(target).attr('data-scroll-offset')
    targetOffset = targetOffset - (parseInt(customOffset) || 0)
    $(scrollElem).animate
      scrollTop: targetOffset
    , 800

  # , ->
  # - 210
  #   location.hash = target

  $("a[href*=#]").each ->
    thisPath = filterPath(@pathname) or locationPath
    if locationPath is thisPath and (location.hostname is @hostname or not @hostname) and @hash.replace(/#/, "")
      $target = $(@hash)
      target = @hash
      if target && $target.offset()
        targetOffset = $target.offset().top
        $(this).click (event) ->
          event.preventDefault()
          scrollToElement(target, targetOffset)