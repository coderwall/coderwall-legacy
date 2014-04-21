---
title: "Represent: Get geek cred on your blog"
posted: Tue, 10 Jan 2012 12:04:36 -0800
author: bguthrie
---
Besides just generally causing a lot of mayhem, one of my first real tasks at Coderwall has been to get everyone set up with an official way to integrate Coderwall with their blog. You can see [an example of this on my blog here](http://blog.brianguthrie.com). In this I'm hugely thankful for the efforts of existing similar open-source implementations of Coderwall blog badges; in particular, both Mihail Szabolcs' [Proudify](https://github.com/icebreaker/proudify) ([see it in action](http://proudify.me/)) and Mikael Brevik's [Metabrag](https://github.com/mikaelbr/metabrag) are extremely cool, and absolutely gorgeous to boot.

To integrate it, you need to include the requisite JS and CSS on your blog or web page. (This first pass of the badge requires jQuery; if you'd like support for other frameworks, let us know.)

<script src="https://gist.github.com/1585413.js?file=coderwall_badge_markup.html"></script>

The `data-coderwall-username` attribute is required in order for the script to figure out whose badges to retrieve. `data-coderwall-orientation` is optional (default is vertical) but it helps it make some styling choices depending on where you'd like to place the widget.

In my case, I tacked on a bit of CSS to my existing stylesheets to get the badges placed in the right spot on the page:

<script src="https://gist.github.com/1585413.js?file=coderwall_badge_style.css"></script>

That's all! If you have any other questions, don't hesitate to [get in touch](mailto:brian@coderwall.com). Happy hacking!