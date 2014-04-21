<!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
        <head>
            <title>
            jespern / par2-drobofs / descendants &mdash; Bitbucket
            </title>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta name="description" content="" />
            <meta name="keywords" content="" />
            <!--[if lt IE 9]>
            <script src="https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/js/lib/html5.js"></script>
            <![endif]-->

            <script>
            (function (window) {
                // prevent stray occurrences of `console.log` from causing errors in IE
                var console = window.console || (window.console = {});
            console.log || (console.log = function () {});

            var BB = window.BB || (window.BB = {});
            BB.debug = false;
            BB.cname = false;
            BB.CANON_URL = 'https://bitbucket.org';
            BB.MEDIA_URL = 'https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/';
            BB.images = {
                noAvatar: 'https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/img/no_avatar.png'
                };
            BB.user = {"isKbdShortcutsEnabled": true, "isSshEnabled": false};
            BB.user.has = (function () {
                var betaFeatures = [];
                betaFeatures.push('repo2');
                return function (feature) {
                return _.contains(betaFeatures, feature);
                };
            }());
            BB.targetUser = BB.user;

            BB.repo || (BB.repo = {});

            BB.user.isAdmin = false;
            BB.repo.id = 385667;


            BB.repo.language = null;
            BB.repo.pygmentsLanguage = null;


            BB.repo.slug = 'par2\u002Ddrobofs';


            BB.repo.owner = {
                username: 'jespern'
                };

            // Coerce `BB.repo` to a string to get
            // "davidchambers/mango" or whatever.
            BB.repo.toString = function () {
                return BB.cname ? this.slug : this.owner.username + '/' + this.slug;
                }




            }(this));
            </script>


            <link rel="stylesheet" href="https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/bun/css/bundle.css"/>


            <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="Bitbucket" />
            <link rel="icon" href="https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/img/logo_new.png" type="image/png" />
            <link type="text/plain" rel="author" href="/humans.txt" />


            <script src="https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/bun/js/bundle.js"></script>


        </head>

        <body id="" class="">
            <script>
            if (navigator.userAgent.indexOf(' AppleWebKit/') === -1) {
                $('body').addClass('non-webkit')
                }
            $('body')
            .addClass($.client.os.toLowerCase())
            .addClass($.client.browser.toLowerCase())
            </script>
            <!--[if IE 8]>
            <script>jQuery(document.body).addClass('ie8')</script>
            <![endif]-->
            <!--[if IE 9]>
            <script>jQuery(document.body).addClass('ie9')</script>
            <![endif]-->

            <div id="wrapper">


                <div id="header-wrap">
                    <div id="header">
                        <ul id="global-nav">
                            <li>
                                <a class="home" href="http://www.atlassian.com">Atlassian Home</a>
                            </li>
                            <li>
                                <a class="docs" href="http://confluence.atlassian.com/display/BITBUCKET">Documentation</a>
                            </li>
                            <li>
                                <a class="support" href="/support">Support</a>
                            </li>
                            <li>
                                <a class="blog" href="http://blog.bitbucket.org">Blog</a>
                            </li>
                            <li>
                                <a class="forums" href="http://groups.google.com/group/bitbucket-users">Forums</a>
                            </li>
                        </ul>
                        <a href="/" id="logo">Bitbucket by Atlassian</a>

                        <div id="main-nav">

                            <ul class="clearfix">
                                <li>
                                    <a href="/plans">Pricing &amp; signup</a>
                                </li>
                                <li>
                                    <a id="explore-link" href="/explore">Explore Bitbucket</a>
                                </li>
                                <li>
                                    <a href="/account/signin/?next=/jespern/par2-drobofs/descendants">Log in</a>
                                </li>


                                <li class="search-box">

                                    <form action="/repo/all">
                                        <input type="search" results="5" autosave="bitbucket-explore-search"
                                        name="name" id="searchbox"
                                        placeholder="owner/repo" />

                                    </form>
                                </li>

                            </ul>

                        </div>


                    </div>
                </div>

                <div id="header-messages">









                </div>


                <div id="content">
                    <div id="descendants">


                        <script>
                        jQuery(function ($) {
                            var cookie = $.cookie,
                            cookieOptions, date,
                            $content = $('#content'),
                            $pane = $('#what-is-bitbucket'),
                            $hide = $pane.find('[href="#hide"]').css('display', 'block').hide();

                            date = new Date();
                            date.setTime(date.getTime() + 365 * 24 * 60 * 60 * 1000);
                            cookieOptions = { path: '/', expires: date };

                        if (cookie('toggle_status') == 'hide') $content.addClass('repo-desc-hidden');

                        $('#toggle-repo-content').click(function (event) {
                            event.preventDefault();
                            $content.toggleClass('repo-desc-hidden');
                            cookie('toggle_status', cookie('toggle_status') == 'show' ? 'hide' : 'show', cookieOptions);
                            });

                        if (!cookie('hide_intro_message')) $pane.show();

                        $hide.click(function (event) {
                            event.preventDefault();
                            cookie('hide_intro_message', true, cookieOptions);
                            $pane.slideUp('slow');
                            });

                        $pane.hover(
                        function () { $hide.fadeIn('fast'); },
                        function () { $hide.fadeOut('fast'); });

                        (function () {
                            // Update "recently-viewed-repos" cookie for
                            // the "repositories" drop-down.
                            var
                            id = BB.repo.id,
                            cookieName = 'recently-viewed-repos_' + BB.user.id,
                            rvr = cookie(cookieName),
                            ids = rvr? rvr.split(','): [],
                            idx = _.indexOf(ids, '' + id);

                            // Remove `id` from `ids` if present.
                            if (~idx) ids.splice(idx, 1);

                            cookie(
                            cookieName,
                            // Insert `id` as the first item, then call
                            // `join` on the resulting array to produce
                            // something like "114694,27542,89002,84570".
                            [id].concat(ids.slice(0, 4)).join(),
                            {path: '/', expires: 1e6} // "never" expires
                        );
                        }());
                        });
                        </script>


                        <div id="what-is-bitbucket" class="new-to-bitbucket">
                            <h2>Jesper Noehr
                                <span id="slogan">is sharing code with you</span>
                            </h2>
                            <img src="https://secure.gravatar.com/avatar/b658715b9635ef057daf2a22d4a8f36e?d=identicon&s=32" alt="" class="avatar" />
                            <p>Bitbucket is a code hosting site. Unlimited public and private repositories. Free for small teams.</p>
                            <div class="primary-action-link signup">
                                <a href="/account/signup/?utm_source=internal&utm_medium=banner&utm_campaign=what_is_bitbucket">Try Bitbucket free</a>
                            </div>
                            <a href="#hide" title="Don't show this again">Don't show this again</a>
                        </div>


                        <div id="tabs" class="tabs">
                            <ul>
                                <li>
                                    <a href="/jespern/par2-drobofs/overview" id="repo-overview-link">Overview</a>
                                </li>

                                <li>
                                    <a href="/jespern/par2-drobofs/downloads" id="repo-downloads-link">Downloads (
                                        <span id="downloads-count">1</span>
                                    )</a>
                                </li>


                                <li>
                                    <a href="/jespern/par2-drobofs/pull-requests" id="repo-pr-link">Pull requests (0)</a>
                                </li>

                                <li>

                                    <a href="/jespern/par2-drobofs/src" id="repo-source-link">Source</a>

                                </li>

                                <li>
                                    <a href="/jespern/par2-drobofs/changesets" id="repo-commits-link">Commits</a>
                                </li>

                                <li id="wiki-tab" class="dropdown"
                                style="display:
                        none  
        
      ">
                                    <a href="/jespern/par2-drobofs/wiki" id="repo-wiki-link">Wiki</a>
                                </li>

                                <li id="issues-tab" class="dropdown inertial-hover"
                                style="display:
                      none  
        
      ">
                                    <a href="/jespern/par2-drobofs/issues?status=new&amp;status=open" id="repo-issues-link">Issues (0) &raquo;</a>
                                    <ul>
                                        <li>
                                            <a href="/jespern/par2-drobofs/issues/new">Create new issue</a>
                                        </li>
                                        <li>
                                            <a href="/jespern/par2-drobofs/issues?status=new">New issues</a>
                                        </li>
                                        <li>
                                            <a href="/jespern/par2-drobofs/issues?status=new&amp;status=open">Open issues</a>
                                        </li>
                                        <li>
                                            <a href="/jespern/par2-drobofs/issues?status=duplicate&amp;status=invalid&amp;status=resolved&amp;status=wontfix">Closed issues</a>
                                        </li>

                                        <li>
                                            <a href="/jespern/par2-drobofs/issues">All issues</a>
                                        </li>
                                        <li>
                                            <a href="/jespern/par2-drobofs/issues/query">Advanced query</a>
                                        </li>
                                    </ul>
                                </li>


                            </ul>

                            <ul>
                                <li class="selected">
                                    <a href="/jespern/par2-drobofs/descendants" id="repo-forks-link">Forks/queues (0)</a>
                                </li>

                                <li>
                                    <a href="/jespern/par2-drobofs/zealots">Followers (
                                        <span id="followers-count">1</span>
                                    )</a>
                                </li>
                            </ul>
                        </div>


                        <div class="repo-menu" id="repo-menu">
                            <ul id="repo-menu-links">

                                <li>
                                    <a href="/jespern/par2-drobofs/rss" class="rss" title="RSS feed for par2-drobofs">RSS</a>
                                </li>

                                <li>
                                    <a id="repo-fork-link" href="/jespern/par2-drobofs/fork" class="fork">fork</a>
                                </li>


                                <li>
                                    <a id="repo-patch-queue-link" href="/jespern/par2-drobofs/hack" class="patch-queue">patch queue</a>
                                </li>


                                <li>
                                    <a id="repo-follow-link" rel="nofollow" href="/jespern/par2-drobofs/follow" class="follow">follow</a>
                                </li>


                            </ul>


                            <ul class="metadata">




                            </ul>

                        </div>

                        <div class="repo-menu" id="repo-desc">
                            <ul id="repo-menu-links-mini" class="nosource">


                                <li>
                                    <a href="/jespern/par2-drobofs/rss" class="rss" title="RSS feed for par2-drobofs"></a>
                                </li>

                                <li>
                                    <a href="/jespern/par2-drobofs/fork" class="fork" title="Fork"></a>
                                </li>


                                <li>
                                    <a href="/jespern/par2-drobofs/hack" class="patch-queue" title="Patch queue"></a>
                                </li>


                                <li>
                                    <a rel="nofollow" href="/jespern/par2-drobofs/follow" class="follow">follow</a>
                                </li>


                            </ul>

                            <h3 id="repo-heading" class="public hg">
                                <a class="owner-username" href="/jespern">jespern</a>
                            /
                                <a class="repo-name" href="/jespern/par2-drobofs">par2-drobofs</a>


                            </h3>


                            <p class="repo-desc-description">par2cmdline compiled for ARM, drop-and-install for DroboFS</p>


                            <div id="repo-desc-cloneinfo">Clone this repository (size: 544 bytes):
                                <a href="https://bitbucket.org/jespern/par2-drobofs" class="https">HTTPS</a>
                            /
                                <a href="ssh://hg@bitbucket.org/jespern/par2-drobofs" class="ssh">SSH</a>
                                <pre id="clone-url-https">hg clone https://bitbucket.org/jespern/par2-drobofs</pre>
                                <pre id="clone-url-ssh">hg clone ssh://hg@bitbucket.org/jespern/par2-drobofs</pre>

                            </div>

                            <a href="#" id="toggle-repo-content"></a>


                        </div>


                        <h2>Forks</h2>

                        <p>No forks of
                            <a href="/jespern/par2-drobofs/overview">par2-drobofs</a>
                        yet.</p>


                        <h2>Patch queues</h2>

                        <p>No patch queues of
                            <a href="/jespern/par2-drobofs">par2-drobofs</a>
                        yet.</p>


                    </div>
                </div>

            </div>

            <div id="footer">
                <ul id="footer-nav">
                    <li>Copyright © 2013
                        <a href="http://atlassian.com">Atlassian</a>
                    </li>
                    <li>
                        <a href="http://www.atlassian.com/hosted/terms.jsp">Terms of Service</a>
                    </li>
                    <li>
                        <a href="http://www.atlassian.com/about/privacy.jsp">Privacy</a>
                    </li>
                    <li>
                        <a href="//bitbucket.org/site/master/issues/new">Report a Bug to Bitbucket</a>
                    </li>
                    <li>
                        <a href="http://confluence.atlassian.com/x/IYBGDQ">API</a>
                    </li>
                    <li>
                        <a href="http://status.bitbucket.org/">Server Status</a>
                    </li>
                </ul>
                <ul id="social-nav">
                    <li class="blog">
                        <a href="http://blog.bitbucket.org">Bitbucket Blog</a>
                    </li>
                    <li class="twitter">
                        <a href="http://www.twitter.com/bitbucket">Twitter</a>
                    </li>
                </ul>
                <h5>We run</h5>
                <ul id="technologies">
                    <li>
                        <a href="http://www.djangoproject.com/">Django 1.3.1</a>
                    </li>
                    <li>
                        <a href="//bitbucket.org/jespern/django-piston/">Piston 0.3dev</a>
                    </li>
                    <li>
                        <a href="http://git-scm.com/">Git 1.7.6</a>
                    </li>
                    <li>
                        <a href="http://www.selenic.com/mercurial/">Hg 1.9.1</a>
                    </li>
                    <li>
                        <a href="http://www.python.org">Python 2.7.2</a>
                    </li>
                    <li>af93cb6757b0 | bitbucket05</li>
                </ul>
            </div>

            <script src="https://dwz7u9t8u8usb.cloudfront.net/m/e218cff6a4fb/js/lib/global.js"></script>


            <script>
            BB.gaqPush(['_trackPageview']);

            BB.gaqPush(['atl._trackPageview']);





            (function () {
                var ga = document.createElement('script');
                ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                ga.setAttribute('async', 'true');
                document.documentElement.firstChild.appendChild(ga);
                }());
            </script>

        </body>
    </html>
