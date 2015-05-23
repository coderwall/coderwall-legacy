$ ->
  last_zindex = 0

  $("a.close-editor").click (e)->
    sectionSel = $(@).attr("href")
    section = $(sectionSel)
    form = section.find(".form").addClass('hide')
    form.css('z-index', last_zindex)
    e.preventDefault()
    turnUpTheLights()

  $("a.launch-editor, a.activate-editor").click (e)->
    sectionSel = $(@).attr("href")
    section = $(sectionSel)
    form = section.find(".form").removeClass('hide')
    last_zindex = form.css('z-index')
    form.css('z-index', 9999)
    turndownTheLights()

  $('form').on "ajax:beforeSend", (e)->
    submit = $(@).children('input[name="commit"]')
    submit.val("Saving...")

  $('form').on "ajax:error", (e, response, error)->
    if response.status == 422
      errorList = $(@).children("ul.errors")
      errorList.html("")
      data = $.parseJSON(response.responseText)
      i = 0
      while i < data.errors.length
        errorList.prepend("<li>" + data.errors[i] + "</li>")
        i++

  $('form').on "ajax:complete", (e)->
    submit = $(@).children('input[name="commit"]')
    submit.val("Save")

  $('a.add-interview-step').click (e)->
    e.preventDefault()
    $("ol.edit-interview-steps").append("
              <li class='interview-step'>
                <div>
                  <textarea name='team[interview_steps][]'></textarea>
                </div>
                <a class='remove-interview-step' href='#'>Remove</a>
              </li>")


  $('a.remove-interview-step').click (e)->
    e.preventDefault()
    $(@).parents('li.interview-step').remove()

  Chute.setApp('502d8ffd3f59d8200c000097')

  $("a.remove-photo").click (e)->
    e.preventDefault()
    $(@).parent('li.preview-photos').remove()

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

  $("a.photos-chooser").click (e)->
    e.preventDefault()
    width = $(@).attr("data-fit-w")
    Chute.MediaChooser.choose (urls, data)->
      i = 0
      while i < urls.length
        url = Chute.width(width, urls[i])
        setTimeout (->
          Chute.width(width, urls[i])
        ), 1000
        setTimeout (->
          Chute.width(width, urls[i])
        ), 5000
        $("ul.edit-photos").append("
                            <li class='preview-photos'>
                              <input type='hidden' name='team[office_photos][]' value='" + url + "' />
                              <img src='" + url + "'/>
                              <a href='#' class='remove-photo'>Remove</a>
                            </li>")
        i++

  turndownTheLights = ->
    $('#dimmer').css('display', 'block').css('z-index', 1000)

  turnUpTheLights = ->
    $('#dimmer').css('display', 'none').css('z-index', -1000)
