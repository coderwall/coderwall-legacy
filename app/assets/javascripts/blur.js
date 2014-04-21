//source: https://github.com/ceramedia/examples/blob/gh-pages/canvas-blur/v5/canvas-image.js
var CanvasImage = function (element, image) {
    this.image = image;
    this.element = element;
    this.element.width = this.image.width;
    this.element.height = this.image.height;
    //chrome fix. see:    http://code.google.com/p/chromium/issues/detail?id=121780
    var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    var is_mac = navigator.appVersion.indexOf("Mac") > -1;

    if (is_chrome && is_mac) {
        this.element.width = Math.min(this.element.width, 300);
        this.element.height = Math.min(this.element.height, 200);
    }

    this.context = this.element.getContext("2d");
    this.context.drawImage(this.image, 0, 0);
};
CanvasImage.prototype = {
    /**
     * Runs a blur filter over the image.
     *
     * @param {int} strength Strength of the blur.
     */
    blur: function (strength) {
        this.context.globalAlpha = 0.5; // Higher alpha made it more smooth
        // Add blur layers by strength to x and y
        // 2 made it a bit faster without noticeable quality loss
        for (var y = -strength; y <= strength; y += 2) {
            for (var x = -strength; x <= strength; x += 2) {
                // Apply layers
                this.context.drawImage(this.element, x, y);
                // Add an extra layer, prevents it from rendering lines
                // on top of the images (does makes it slower though)
                if (x >= 0 && y >= 0) {
                    this.context.drawImage(this.element, -(x - 1), -(y - 1));
                }
            }
        }
        this.context.globalAlpha = 1.0;
    }
};

$(function () {
    var image, canvasImage, element;

    $('.blur').each(function () {
        element = this;
        image = new Image();
        image.onload = function () {
            canvasImage = new CanvasImage(element, this);
            canvasImage.blur(4);
        }
        image.src = $(this).attr('src');
    });
})