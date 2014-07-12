#= require      ./coderwall
#= require      ./models/team
#= require      ./controllers/teams
#= require_tree ./templates/teams
#= require_tree ./helpers
#= require_tree ./views/teams
#= require      search

$ ->
  search_teams = (name, country) ->
    query = 'q=' + name
    query += '&country=' + country if country?
    #    Coderwall.teamsController.clearAll()
    #    $.getJSON encodeURI('/teams/search?' + query), (teams) ->
    #      Coderwall.teamsController.loadAll teams
    $.getScript encodeURI('/teams/search?' + query)

  $('.country-link').click ->
    search_teams("*", $(this).find('.country-name').text())

  searchBox.enableSearch('#teams-search', search_teams)
  $('form.network-search').submit (e)->
    e.preventDefault()
    query = $('#teams-search').val()
    query = "" if query == $('#teams-search').attr('placeholder')
    search_teams(query, null)