//= require jquery
//= require jquery_ujs
//= require jquery.tipTip.min
//= require jquery.sortElements
//= require jquery.fancybox.min
//= require jquery.autocomplete
//= require jquery.flexslider-min
//= require underscore
//= require backbone

//= require jquery-dropdown

$(function () {
  $('a.remove-parent').live('click', function (e) {
    $(this).parents('.' + $(this).attr('data-parent')).slideUp();
    e.preventDefault();
  });
  registerButtons();
})

$(function () {
  $('[placeholder]').focus(function () {
    var input = $(this);
    if (input.val() == input.attr('placeholder')) {
      input.val('');
      input.removeClass('placeholder');
    }
  }).blur(function () {
    var input = $(this);
    if (input.val() == '' || input.val() == input.attr('placeholder')) {
      input.addClass('placeholder');
      input.val(input.attr('placeholder'));
    }
  }).blur();

  $('.save a').live('click', function (e) {
    var form = $(this).parents('form');
    $.post(form.attr('action'), form.serialize()).success(function (response) {

    });
    e.preventDefault();
  })

  $('a.submitEndorsement').live('click', function (e) {
    var form = $(this).parents('form');
    $.post(form.attr('action'), form.serialize()).success(function (response) {
      $.fancybox.close();
      setTimeout(function () {
        $('#endorsementcounter span').slideUp();
      }, 600);
      setTimeout(function () {
        $('#endorsementcounter span').html(response.totalEndorsements).slideDown();
        if (response.availableEndorsements <= 0) {
          $('#endorse .endorsements').remove();
          $('#endorse .notification').remove();
          $('#endorse .message').html("You used up all your endorsements. Unlock additional achievements to make more endorsements.");
        } else if (response.remainingEndoresments <= 0) {
          $('#endorse .endorsements').remove();
          $('#endorse .notification').remove();
          $('#endorse .message').html("There are no more skills to endorse.");
        } else {
          $('#endorse .notification').html(response.message);
          $(response.ensorsementsMade).each(function () {
            $('#' + this).remove();
          });
        }
      }, 1500);
    });
    e.preventDefault();
  })

  $('#nocount input, #withcount input').live('change', function () {
    $('.endorseButtons .markdown, .endorseButtons .html, .endorseButtons .textile').toggleClass('hide');
  });

  $('a.seeMore').live('click', function (e) {
    $(this).siblings('.seeMore').slideDown();
    e.preventDefault();
  });

  $('#achievementcode  a').live('click', function () {
    $(this).hide().parents('em').hide();
    $('.claimcode').fadeIn();
    e.preventDefault();
  });

  $(".tip").tipTip({maxWidth: "auto", edgeOffset: 10});

  $("a.filter").click(function (e) {
    $('a.filter').removeClass('active');
    $(this).addClass('active');

    var list = $(this).attr('data-list');
    var filter = $(this).attr('data-filter');

    if (filter == '') {
      $(list).removeClass('suppress');
    }
    else {
      $(list).removeClass('suppress').addClass('suppress');
      $(list + '.' + filter).removeClass('suppress');
    }
    sortListItems(list, filter);
    e.preventDefault();
  });

  $("a.fancybox").fancybox({
    hideOnContentClick: false,
    margin: 0,
    padding: 0,
    onClosed: function () {
      $(this.href).find("form").each(function () {
        this.reset();
      });
    }
  });

  $("a.closefancybox").live("click", function (e) {
    $.fancybox.close();
  });

  $('.event_links a.more').live('click', function (e) {
    $(this).siblings('.more.hide').slideToggle();
    e.preventDefault();
  });

  if ($('.featuredAccomplishment').length > 0) {
    setInterval(function () {
      var element = $('.featuredAccomplishment:not(.hide)').fadeOut().delay(1000).addClass('hide');
      if (element.next().length > 0)
        element.next().removeClass('hide').fadeIn();
      else
        $('.featuredAccomplishment:first').removeClass('hide').fadeIn();
    }, 6000);
  }

  $('.attentionSpan').first().each(function () {
    $(this).slideDown().next().delay(1500).slideDown();
  });
  $('.attentionSpan.disappear').delay(4000).slideUp();

  //replace authenticity token with the meta tag to make sure cached fragments are not being exposed
  $('input[name=authenticity_token]').val($('meta[name=csrf-token]').attr('content'))
});

function sortListItems(list, value) {
  $(list).sortElements(function (x, y) {
    if ($(x).hasClass(value) == true && $(y).hasClass(value) == true) {
      if ($(x).attr('data-popularity') > $(y).attr('data-popularity'))
        return -1;
      else
        return 1;
    }
    else if ($(x).hasClass(value) == true && $(y).hasClass(value) == false) {
      return -1;
    } else {
      return 1;
    }
  });
}

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
}

function updateCountdown(e) {
  var remaining = 100 - $('#new_accomplishment').val().length;
  if (remaining <= 0) {
    $('#new_accomplishment').val($('#new_accomplishment').val().substring(0, 100));
    $('#countdown').text('0');
  }
  else
    $('#countdown').text(remaining);
}

function toggleNewAccomplishment() {
  $('.accomplishments .featured').toggle();
  $('.accomplishments .addnew').toggle();
  $('#new_accomplishment').val('');
}

function handle_redirect(response) {
  if (response.status == "redirect")
    window.location = response.to
}

function registerButtons() {
  $("a.follow-team:not(.noauth)").live("click", function (e) {
    $(this).toggleClass("following");
    return e.preventDefault();
  });
}
