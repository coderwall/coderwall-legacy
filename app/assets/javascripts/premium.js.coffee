#= require jquery.modal.js
#= require jquery.masonry.min.js

$ ->
  mapElement = document.getElementById("location-map")

  map = new google.maps.Map(mapElement,
    zoom: 11
    disableDefaultUI: true
    scrollwheel: false,
    navigationControl: false,
    mapTypeControl: false,
    scaleControl: false,
    draggable: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  ) if mapElement?

  positionOnAddress = (address)->
    new google.maps.Geocoder().geocode
      address: address
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        point = results[0].geometry.location
        offset = new google.maps.LatLng(point.lat(), point.lng() + 0.15)
        map.setCenter offset
        marker = new google.maps.Marker(
          map: map
          position: point
        )
      else
        console.log "Geocode was not successful for the following reason: " + status

  featureLocation = (element)->
    $("a.mapLocation").show()
    element.hide()
    name = element.children(".name").text()
    desc = element.children(".description").text()
    address = element.children(".address").text()
    pois = element.children(".poi").html()
    positionOnAddress(address)
    $(".location-details .selected h3").text(name)
    $(".location-details .selected .address").text(address)
    $(".location-details .selected .description").text(desc)
    $(".location-details .selected .poi").html(pois)

  $(document).on "click", "a.mapLocation", (e)->
    featureLocation($(@))
    e.preventDefault()

  positionOnAddress($(".location-details .selected .address").text())

  showCloseupOnMember = (memberElement)->
    $("a.show-closeup").removeClass("active")
    $(".about-members").html(memberElement.siblings(".member_expanded").children().clone())
    memberElement.addClass("active")

  $(document).on "click", "a.show-closeup", (e)->
    showCloseupOnMember($(@))
    e.preventDefault()

  moveLeft = ()->
    first_5_visible = $("li.member:visible").slice(1, 6)
    first_5_visible.addClass('hide')
    last_visible = $("li.member:visible:first")
    members_to_show = last_visible.prevAll().slice(0, 5)
    $("a.arrow.right").removeClass('disable')
    if last_visible.prevAll().length < 6
      $("a.arrow.left").addClass('disable')
    members_to_show.removeClass('hide')
    showCloseupOnMember(last_visible.children("a.show-closeup"))

  moveRight = ()->
    first_5_visible = $("li.member:visible").slice(0, 5)
    first_5_visible.addClass('hide')
    last_visible = $("li.member:visible:first")
    members_to_show = last_visible.nextAll().slice(0, 5)
    $("a.arrow.left").removeClass('disable')
    if members_to_show.length < 5
      $("a.arrow.right").addClass('disable')
    members_to_show.removeClass('hide')
    showCloseupOnMember(last_visible.children("a.show-closeup"))

  $(document).on "click", "a.arrow.right:not(.disable)", (e)->
    e.preventDefault()
    moveRight()

  $(document).on "click", "a.arrow.left:not(.disable)", (e)->

    e.preventDefault()
    moveLeft()

  autoOrganizePhotos()
  enableScrollMeasurement()
  registerExitRecording()
  registerApplication()

  # $('ul.auto-organize').each ()->
  #   container = $(@)
  #   width     = parseInt(container.attr('data-column-width'))
  #   gutter    = parseInt(container.attr('data-gutter-width'))
  #   container.imagesLoaded ->
  #     container.masonry
  #       itemSelector: "li"
  #       columnWidth: width
  #       gutterWidth: gutter
  #       isFitWidth: true

  $('.active-opportunity, .inactive-opportunity').on 'click', ->
    $(@).toggleClass('active-opportunity')
    $(@).toggleClass('inactive-opportunity')

$(document).ajaxComplete (e, xhr, options)->
  handle_redirect(xhr)

autoOrganizePhotos = ->
  container = $('.images.auto-organize')
  width = parseInt(container.attr('data-column-width'))
  gutter = parseInt(container.attr('data-gutter-width'))
  container.imagesLoaded ->
    container.masonry
      itemSelector: "li"
      columnWidth: width
      gutterWidth: gutter
      isFitWidth: true

enableScrollMeasurement = ->
  $.scrollDepth(
    elements: ['section'] # Track DOM elements | Default: []
    percentage: false # Don't track depth percentage | Default: true
    eventHandler: updateFurthestScrolled
  )

updateFurthestScrolled = (action, label, timing)->
  unless label == "Baseline"
    element = $('#furthest-scrolled')
    element.attr('data-section', label)
    element.attr('data-time-spent', timing)

window.recordedEngagement = false

registerExitRecording = ->
  $('a.record-exit').on 'click', ->
    recordOpportunityView($(this))
    recordEngagement($(this).attr('href'), $(this).attr('data-target-type'))
    window.recordedEngagement = true

  $(window).on 'unload', ->
    recordEngagement(null, 'left') unless window.recordedEngagement

recordEngagement = (exit_url, exit_target_type)->
  action = $('#record-exit-path').attr('data-record-path')
  data =
    exit_url: exit_url,
    exit_target_type: exit_target_type,
    furthest_scrolled: $('#furthest-scrolled').attr('data-section'),
    time_spent: $('#furthest-scrolled').attr('data-time-spent')
  async = if exit_url? then true else false
  $.ajaxSetup({async: false})
  $.ajax(
    type: "POST",
    url: action,
    data: data,
    async: async,
    dataType: "json"
  ) if action?


recordOpportunityView = (element)->
  action = element.attr("data-opportunity-visit-path")
  $.post(action) if action?

window.add_fields = (link, association, content)->
  new_id = new Date().getTime()
  regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id))

registerApplication = ->
  $('.apply:not(.noauth)').on 'click', (e)->
    e.preventDefault()
    $(this).closest('.job-panel').find('.application').toggleClass('hide')
    $(this).toggleClass('hide-application')

  $('input[type=file]').on 'change', ->
    uploading_begin_text = "Your resume is uploading ..."
    uploading_finished_text = "Send your resume using the button below."

    form      = $(this).closest('form')
    status    = $(".application p.status")
    status.text(uploading_begin_text)

    formData  = new FormData(form.get(0))

    # Using a timeout due to weird behavior with change event
    # on file input.  In testing, browser would not redraw until this
    # change function returned, therefore the status text above was never displayed
    send_request = ()->
      req = $.ajax
        url: form.attr('action')
        data: formData
        cache: false
        processData: false
        contentType: false
        type: 'POST'

      req.done (data,response,xhr)->
        $(".send-application.disabled").removeClass("disabled").css("display","block")
        form.css("display","none")
        status.text(uploading_finished_text)
        return

    setTimeout(send_request, 100)
    return


  $('a.send-application:not(.applied)').on 'click', (e)->
    $(this).href('#already-applied')
