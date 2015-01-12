$ ->
  # if the query is not empty, then make it active to see the text better
  if $('input.query').val() != $('input.query').attr('placeholder') && $('input.query').val().length > 0
    $('input.query').addClass('active')

  # after a change in keywords input, if the query is not empty, then make it active to see the text better
  $('input.query').on 'change', (e) ->
    if $(this).val().length > 0
      $(this).addClass('active')
    else
      $(this).removeClass('active')

  # make sure the placeholder for the keywords input form doesn't get sent as the query
  $('#filter-jobs').on 'submit', (e) =>
    if $('input.query').attr('placeholder') == $('input.query').val()
      $('input.query').val('')