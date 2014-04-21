$(function () {
    var username = $("#user_username");
    var message = $("#username_validation");

    username.live('blur', validateUsername);

    function validateUsername() {
        message.stop();
        message.show().html('Validating your username....');
        var verificationUrl = username.attr('data-validation') + "/" + username.val();
        $.get(verificationUrl,function (data) {
            message.show().removeClass('failed').html("Great username! It's all yours.").delay(5000).fadeOut();
        }).error(function (data) {
            message.show().addClass('failed').html('That username has already been taken!');
        });
    }

    validateUsername();
});