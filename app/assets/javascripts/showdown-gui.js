window.onload = startGui;

var converter;
var convertTextTimer, convertBodyTimer, convertTitleTimer, convertTagsTimer, processingTime;
var lastText;
var lastOutput, lastRoomLeft;
var inputPane, previewPane;


function startGui() {
    inputPane = $('.x-tip-content.edit #protip_body')[0];
    previewPane = $('.x-tip-content.preview #body')[0];

    // if (typeof previewPane === "undefined") 
    //   alert('why');


    titleContent = $('.x-tip-content.edit #protip_title')[0];
    titlePreview = $('.x-tip-content.preview #title')[0];
    tagsContent = $('.x-tip-content.edit #protip_tags')[0];
    tagsPreview = $('.x-tip-content.preview #tags')[0];

    // set event handlers
    window.onresize = setPaneHeights;

    // First, try registering for keyup events
    // (There's no harm in calling onInput() repeatedly)
    //window.onkeyup = function() {onInput(convertText)};
    inputPane.onkeyup = function () {
        onInput(convertBody)
    };
    titleContent.onkeyup = function () {
        onInput(convertTitle)
    };
    tagsContent.onkeyup = function () {
        onInput(convertTags)
    };

    // In case we can't capture paste events, poll for them
    var pollingFallback = window.setInterval(function () {
        if (inputPane.value != lastText[inputPane.getAttribute('id')])
            onInput(convertText);
    }, 1000);

    // Try registering for paste events
    inputPane.onpaste = function () {
        // It worked! Cancel paste polling.
        if (pollingFallback != undefined) {
            window.clearInterval(pollingFallback);
            pollingFallback = undefined;
        }
        onInput(convertText);
    }

    // Try registering for input events (the best solution)
    if (inputPane.addEventListener) {
        // Let's assume input also fires on paste.
        // No need to cancel our keyup handlers;
        // they're basically free.
        inputPane.addEventListener("input", inputPane.onpaste, false);
    }

    // poll for changes in font size
    // this is cheap; do it often
    window.setInterval(setPaneHeights, 250);

    // start with blank page?
    if (top.document.location.href.match(/\?blank=1$/))
        inputPane.value = "";

    // build the converter
    converter = new Showdown.converter();

    lastText = {};

    // do an initial conversion to avoid a hiccup
    convertText();
    // start the other panes at the top
    // (our smart scrolling moved them to the bottom)
    previewPane.scrollTop = 0;
}

function textChanged(source) {
    // get input text
    var text = source.value;

    // if there's no change to input, cancel conversion
    if (text && text == lastText[source.getAttribute('id')]) {
        return false;
    } else {
        lastText[source.getAttribute('id')] = text;
        return true;
    }
}

//
//	Conversion
//

function convertText() {
    convertTitle();
    convertBody();
    convertTags();
};

function convertBody() {
    if (textChanged(inputPane)) {
        text = inputPane.value;
        // Do the conversion
        text = converter.makeHtml(text);

        // save proportional scroll positions
        saveScrollPositions();

        previewPane.innerHTML = text;

        hljs.initHighlighting()

        lastOutput = text;

        // restore proportional scroll positions
        restoreScrollPositions();
    }
}

function convertTitle() {
    if (textChanged(titleContent)) {
        titlePreview.innerHTML = titleContent.value;
    }
}

function convertTags() {
    if (textChanged(tagsContent)) {

        $(tagsPreview).empty();
        NoWhiteSpace = function (element) {
            return element.replace(/^\s+|\s+$/g, '');
        }
        addTags(tagsPreview, tagsContent.value.split(",").map(NoWhiteSpace).filter(Boolean));
    }
}

function addTags(ul, list) {
    $.each(list, function (i, tag) {
        $(ul).append($('<li>').append($('<a>').text(tag)));
    });
}

//
//	Event handlers
//


function onInput(converter) {
// In "delayed" mode, we do the conversion at pauses in input.
// The pause is equal to the last runtime, so that slow
// updates happen less frequently.
//
// Use a timer to schedule updates.  Each keystroke
// resets the timer.
    switch (converter.name) {
        case "convertText":
            resetTimers();
            activateTimer(convertTextTimer, converter);
            break;
        case "convertBody":
            activateTimer(convertBodyTimer, converter);
            break;
        case "convertTitle":
            activateTimer(convertTitleTimer, converter);
            break;
        case "convertTags":
            activateTimer(convertTagsTimer, converter);
            break;
    }
}

function activateTimer(timer, converter) {
    // if we already have convertText scheduled, cancel it
    if (timer) {
        window.clearTimeout(timer);
        timer = undefined;
    }

    // Schedule convertxxx().
    // Even if we're updating every keystroke, use a timer at 0.
    // This gives the browser time to handle other events.
    timer = window.setTimeout(converter, processingTime);
}

function resetTimers() {
    convertTextTimer = convertBodyTimer = convertTitleTimer = convertTagsTimer = undefined;
}

//
// Smart scrollbar adjustment
//
// We need to make sure the user can't type off the bottom
// of the preview and output pages.  We'll do this by saving
// the proportional scroll positions before the update, and
// restoring them afterwards.
//

var previewScrollPos;

function getScrollPos(element) {
    // favor the bottom when the text first overflows the window
    if (element.scrollHeight <= element.clientHeight)
        return 1.0;
    return element.scrollTop / (element.scrollHeight - element.clientHeight);
}

function setScrollPos(element, pos) {
    element.scrollTop = (element.scrollHeight - element.clientHeight) * pos;
}

function saveScrollPositions() {
    previewScrollPos = getScrollPos(previewPane);
}

function restoreScrollPositions() {
    // hack for IE: setting scrollTop ensures scrollHeight
    // has been updated after a change in contents
    previewPane.scrollTop = previewPane.scrollTop;

    setScrollPos(previewPane, previewScrollPos);
}

//
// Textarea resizing
//
// Some browsers (i.e. IE) refuse to set textarea
// percentage heights in standards mode. (But other units?
// No problem.  Percentage widths? No problem.)
//
// So we'll do it in javascript.  If IE's behavior ever
// changes, we should remove this crap and do 100% textarea
// heights in CSS, because it makes resizing much smoother
// on other browsers.
//

function getTop(element) {
    var sum = element.offsetTop;
    while (element = element.offsetParent)
        sum += element.offsetTop;
    return sum;
}

function getElementHeight(element) {
    var height = element.clientHeight;
    if (!height) height = element.scrollHeight;
    return height;
}

function getWindowHeight(element) {
    if (window.innerHeight)
        return window.innerHeight;
    else if (document.documentElement && document.documentElement.clientHeight)
        return document.documentElement.clientHeight;
    else if (document.body)
        return document.body.clientHeight;
}

function setPaneHeights() {
    var textarea = inputPane;

    var windowHeight = getWindowHeight();
    var footerHeight = 200;
    var textareaTop = getTop(textarea);

    // figure out how much room the panes should fill
    var roomLeft = windowHeight - footerHeight - textareaTop;

    if (roomLeft < 0) roomLeft = 0;

    // if it hasn't changed, return
    if (roomLeft == lastRoomLeft) {
        return;
    }
    lastRoomLeft = roomLeft;
}