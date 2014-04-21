#handle google map
if google?
  google.load "visualization", "1", packages: [ "geochart" ]
  google.setOnLoadCallback ->
    drawRegionsMap null, 1

  worldmap_options =
    height: 55
    backgroundColor: "#333"
    "tooltip.textStyle":
      fontSize: 8
    legend: false

  worldmap_chart = null

  window.worldmap_chart = ->
    null

  drawRegionsMap = (chosen, rank) ->
    countries = ["worldwide", chosen]
    countries_map = [
      ['Country', 'Rank']
    ].concat([country, rank] for country in countries)
    data = google.visualization.arrayToDataTable(countries_map)

    worldmap_chart = if window.worldmap_chart? window.worldmap_chart
    else new google.visualization.GeoChart(document.getElementById("worldmap"))
    worldmap_chart.draw data, worldmap_options

  $(".country-link").click ->
    drawRegionsMap $(this).data('code').trim(), $(this).data('rank')


window.searchBox =
  search_timer: null
  registerDelayedSearch: (element, search_trigger_func) ->
    element.keydown ->
      self = @
      if $(element).val().length >= ($(element).data('min-match') || 1)
        clearTimeout search_timer
        search_timer = setTimeout ->
          search_trigger_func self
          clearTimeout search_timer
        , 500

  enableSearch: (selector, search_func) ->
    search_timer = null
    $(selector).keydown ->
      clearTimeout search_timer
      search_timer = setTimeout ->
        search_func($(selector).val(), null)
      , 300

    searchBox.registerDelayedSearch($('.delayed-search'), (element) ->
      event = $.Event("keydown")
      event.which = event.keyCode = 13 #enter
      $(element).trigger(event))


