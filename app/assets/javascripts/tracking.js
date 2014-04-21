$(function () {
    $(".track").on('click.tracking', function (e) {
        track_click(this, e)
    });
});

function track_click(link, e) {
    properties = $(link).attr('data-properties');
    if (properties == undefined || properties == null) {
        properties = {};
    }

    e.preventDefault();
    e.stopImmediatePropagation();
    $(link).off('click.tracking');
    logUsage($(link).attr('data-action'), $(link).attr('data-from'), properties, link);

    setTimeout(function () {
        doActualClick(link);
    }, 300);
}


function doActualClick(link) {
    if (link != undefined) {
        $(link).off('click.tracking');
        $(link)[0].click();
        $(link).on('click.tracking', function (e) {
            track_click(this, e)
        });
    }
}

function logUsage(action, context, properties, link_element) {
    var googleCodeLoaded = "undefined" === typeof(_gaq);
    var actionName = action.replace('_', ' ');

    if (googleCodeLoaded) {
        console.log('Record Event: ' + action + ' from ' + context);
    }
    else {
        _gaq.push(['_trackEvent', 'actions', action]);

    }

    if (/^view (.+)/.test(actionName) && $.isEmptyObject(properties)) {
        properties = {'what': actionName.match(/^view (.+)/)[1]};
        actionName = 'view';
    }
    properties = $.extend(context == null ? {} : {'from': context}, properties);

    mixpanel.track(actionName, properties, function (status) {
//          doActualClick(link_element);
        console.log((status == 1 ? "tracked" : "failed") + ":" + actionName);
    });
}
