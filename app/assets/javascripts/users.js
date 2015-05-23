$(function () {

    $('a.add-to-network:not(.noauth)').click(function (e) {
        var follow_button = $(this);
        follow_button.toggleClass('following');
        e.preventDefault();
    });

    $('.skill-left > ul > li').hover(function (e) {
        $(this).parents('ul.skills li').children('.details').slideDown();
    });

    $('ul.skills > li').mouseleave(function (e) {
        $(this).children('.details').slideUp();
    });

    $('a.endorsed').click(function (e) {
        e.preventDefault();
    });

    $('a[href="#addskill"]').click(function (e) {
        $('#add-skill').slideDown();
        e.preventDefault();
    });

    $('.embed-code-button').click( function (e) {
        $('.embed-codes').is('.shown') ? $('.embed-codes').slideUp() : $('.embed-codes').slideDown();
        $('.embed-codes, .show-embed-codes').toggleClass('shown');
        $('.embed-codes').toggleClass('hide');

        e.preventDefault();
    });

    $('a.endorse:not(.endorsed, .not-signed-in)').click(function (e) {
        var link = $(this);
        var form = link.parents('form');
        link.addClass('endorsed');
        $.post(form.attr('action'), form.serialize()).success(function (response) {
            if (response.unlocked)
                link.parents('li').removeClass('locked').addClass('unlocked');
            else
                $('.help-text[data-skill="' + link.attr('data-skill') + '"]').text(response.message);
        });
        e.preventDefault();
    });

    var signedInUsersEndorsements = '[data-user="' + readCookie('identity') + '"]';
    $(signedInUsersEndorsements).each(function () {
        var skillSignedInUserEndorsed = $('a.endorse[data-skill="' + $(this).attr('data-skill') + '"]');
        skillSignedInUserEndorsed.addClass('endorsed');
    });
});