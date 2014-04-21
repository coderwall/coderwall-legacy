---
title: The hacker's version of an embeddable social button
posted: Mon, 16 Jan 2012 11:02:41 -0800
author: mdeiters
---

We wanted to create the inverse of a "share this" button for developers that deserve recognition when they share awesome code. The typical pattern that Twitter and other websites use is to suggest that you embed an iframe or use Javascript to create a button on the client. This is problematic on many pages that don't allow full embedding of HTML (like a GitHub repo README) and often the html itself is cumbersome. To handle this we decided to build a dynamic "endorse button" generated on demand for every user that is as simple as adding an image tag with an enclosing anchor tag.

[![endorse](http://api.coderwall.com/mdeiters/endorsecount.png)](http://coderwall.com/mdeiters)

<script src="https://gist.github.com/1619631.js?file=embed.html"></script>

(To use it, replace my username (*mdeiters*) with your Coderwall username.)

### Adding the endorsement count to the image with Rmagick

We started by creating an image with similar dimensions to the Tweet This button but we left the count bubble empty:

![empty button](http://coderwall.com/images/endorse-button-with-count.png)

ImageMagick and RMagick make it incredibly easy to add to text to an existing image. We just needed to set the right font styles and then use the <code>text</code> method to write the number of endorsements to the bubble. After tweaking the x and y locations we were set. For this first pass we don't even write the image to the file system: we just use Rails' <code>send_data</code> method to stream the newly created image to the client.

<script src="https://gist.github.com/1622786.js"> </script>

If you'd like to run the above code yourself, make sure to install ImageMagick and to include RMagick in your Gemfile, as above.

### Performance

Being a start up, we are firm believers in JIT development which applies to scaling too. We wanted to do the quickest thing to get this out to coderwall members while having a clear path to scale the infrastructure in the future if we need to. For example, using the different api.coderwall.com domain, we have the ability to independently scale the endorse button processes from the rest of the coderwall website.

Rendering a dynamic image can be expensive but our current performance metrics are *acceptable* because we aggressively use HTTP caching. Heroku's robust HTTP caching will serve the same member's endorse button for at least 1 minute because we set a Cache-Control header to public with a future 1 minute expiration date. After that expires, we still have etags and last modified HTTP headers to ensure a new button is generated only if the member receives a new endorsement. Rails' <code>stale?</code> and <code>expires_in</code> makes this incredibly easy.

<script src="https://gist.github.com/1622977.js?file=http_caching_on_controller.rb"></script>

