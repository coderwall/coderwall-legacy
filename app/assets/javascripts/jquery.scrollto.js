/**
 * @depends jquery
 * @name jquery.scrollto
 * @package jquery-scrollto {@link http://balupton.com/projects/jquery-scrollto}
 */

/**
 * jQuery Aliaser
 */
(function ($) {

    /**
     * jQuery ScrollTo (balupton edition)
     * @version 1.0.1
     * @date August 31, 2010
     * @since 0.1.0, August 27, 2010
     * @package jquery-scrollto {@link http://balupton.com/projects/jquery-scrollto}
     * @author Benjamin "balupton" Lupton {@link http://balupton.com}
     * @copyright (c) 2010 Benjamin Arthur Lupton {@link http://balupton.com}
     * @license MIT License {@link http://creativecommons.org/licenses/MIT/}
     */
    if (!($.ScrollTo || false)) {
        $.ScrollTo = {
            /**
             * The Default Configuration
             */
            config: {
                duration: 400,
                easing: 'swing',
                callback: undefined,
                durationMode: 'each'
            },

            /**
             * Configure ScrollTo
             */
            configure: function (options) {
                var ScrollTo = $.ScrollTo;

                // Apply Options to Config
                $.extend(ScrollTo.config, options || {});

                // Chain
                return this;
            },

            /**
             * Perform the Scroll Animation for the Collections
             * We use $inline here, so we can determine the actual offset start for each overflow:scroll item
             * Each collection is for each overflow:scroll item
             */
            scroll: function (collections, config) {
                var ScrollTo = $.ScrollTo;

                // Determine the Scroll
                var collection = collections.pop(),
                    $container = collection.$container,
                    $target = collection.$target;

                // Prepare the Inline Element of the Container
                var $inline = $('<span/>').css({
                    'position': 'absolute',
                    'top': '0px',
                    'left': '0px'
                });
                var position = $container.css('position');

                // Insert the Inline Element of the Container
                $container.css('position', 'relative');
                $inline.appendTo($container);

                // Determine the Offsets
                var startOffset = $inline.offset().top,
                    targetOffset = $target.offset().top,
                    offsetDifference = targetOffset - startOffset;

                // Reset the Inline Element of the Container
                $inline.remove();
                $container.css('position', position);

                // Prepare the callback
                var callback = function (event) {
                    // Check
                    if (collections.length === 0) {
                        // Callback
                        if (typeof config.callback === 'function') {
                            config.callback.apply(this, [event]);
                        }
                    }
                    else {
                        // Recurse
                        ScrollTo.scroll(collections, config);
                    }
                    // Return true
                    return true;
                };

                // Perform the Scroll
                $container.animate({
                    'scrollTop': offsetDifference + 'px'
                }, config.duration, config.easing, callback);

                // Return true
                return true;
            },

            /**
             * ScrollTo the Element using the Options
             */
            fn: function (options) {
                var ScrollTo = $.ScrollTo;

                // Prepare
                var $target = $(this);
                if ($target.length === 0) {
                    // Chain
                    return this;
                }

                // Fetch
                var $container = $target.parent(),
                    collections = [];

                // Handle Options
                config = $.extend({}, ScrollTo.config, options);

                // Cycle through the containers
                while ($container.length === 1 && !$container.is('body') && !($container.get(0) === document)) {
                    // Check Container
                    var container = $container.get(0);
                    if ($container.css('overflow-y') !== 'visible' && container.scrollHeight !== container.clientHeight) {
                        // Push the Collection
                        collections.push({
                            '$container': $container,
                            '$target': $target
                        });
                        // Update the Target
                        $target = $container;
                    }
                    // Update the Container
                    $container = $container.parent();
                }

                // Add the final collection
                collections.push({
                    '$container': $($.browser.msie ? 'html' : 'body'),
                    '$target': $target
                });

                // Adjust the Config
                if (config.durationMode === 'all') {
                    config.duration /= collections.length;
                }

                // Handle
                ScrollTo.scroll(collections, config);

                // Chain
                return this;
            },

            /**
             * Construct
             */
            construct: function (options) {
                var ScrollTo = $.ScrollTo;

                // Apply our jQuery Function
                $.fn.ScrollTo = ScrollTo.fn;

                // Apply our Options to the Default Config
                ScrollTo.config = $.extend(ScrollTo.config, options);

                // Chain
                return this;
            }
        };

        // Construct It
        $.ScrollTo.construct();
    }
    else {
        window.console.warn("$.ScrollTo has already been defined...");
    }

})(jQuery);