#= require jquery.modal.js

$ ->
  top = $("#team-nav").offset().top - parseFloat($("#team-nav").css("margin-top").replace(/auto/, 0))
  fixTeamNavigation = ->
    if $(window).scrollTop() >= top
      $("#team-nav").addClass "fixed"
    else
      $("#team-nav").removeClass "fixed"

  paddingForTeamNavBar = 195
  # 200
  if $.browser.mozilla
    $("#user-close-up").addClass "mozilla"
    paddingForTeamNavBar = 200

  firstProfileTop = $("ul.team-members-list li:eq(1)").offset().top - parseFloat($("ul.team-members-list li:eq(1)").css("margin-top").replace(/auto/,
    0))
  fixUserCloseup = ->
    if $(window).scrollTop() >= firstProfileTop - paddingForTeamNavBar
      $("#user-close-up").addClass "fixed"
    else
      $("#user-close-up").removeClass "fixed"

  $(window).scroll (event) ->
    fixTeamNavigation()
    fixUserCloseup()

  fixTeamNavigation()
  fixUserCloseup()

  $("ul.team-members-list li img").mouseenter ->
    closeUpHtml = $(this).parents("li").find(".user-close-up").clone()
    $("#user-close-up").html(closeUpHtml)

  $("#add-to-team-link").click ->
    $('#add-to-team').modal()