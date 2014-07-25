(function ($) {
    var CODERWALL_API_URL = "http://coderwall.com/:username.json?source=jqcw&callback=?",
        CODERWALL_USER_URL = "http://coderwall.com/:username";

    var DEFAULTS = {
        username: null,
        width: 65,
        opacity: 0.8,
        orientation: "vertical"
    };

    var LOGO_HTML = "" +
        "<div class='coderwall-logo'>" +
        "  <a href='http://coderwall.com'>" +
        "    <img src='http://coderwall.com/images/favicon.png' class='coderwall-icon' />" +
        "    <div class='coderwall-tag-container'>" +
        "      <div class='coderwall-tag-name'>coderwall</div>" +
        "    </div>" +
        "  </a>" +
        "</div>";

    $.fn.coderwall = function (opts) {
        opts = $.extend({}, DEFAULTS, opts);

        return $(".coderwall").each(function () {
            var root = $(this),
                username = $(this).attr("data-coderwall-username") || opts.username,
                width = $(this).attr("data-coderwall-badge-width") || opts.width,
                orientation = $(this).attr("data-coderwall-orientation") || opts.orientation,
                url = CODERWALL_API_URL.replace(/:username/, username);
            if (!jQuery.isEmptyObject(username)) {
                root.addClass("coderwall-root").addClass(orientation);

                $.getJSON(url, function (response) {
                    $(response.data.badges).each(function () {
                        var link = $("<a/>").attr({ href: CODERWALL_USER_URL.replace(/:username/, username) }),
                            img = $("<img/>")
                                .addClass("coderwall-badge")
                                .attr({ src: this.badge, width: width, height: width, alt: this.description });

                        link.append(img);
                        root.append(link);
                    });

                    root.append(LOGO_HTML);
                });
            }
        });
    };

    $(function () {
        $(".coderwall").coderwall();
    });
})(jQuery);