# == Route Map (Updated 2014-02-25 17:02)
#
# Removing XML parsing due to security vulernability. Upgrade to rails ASAP
# Creating scope :near. Overwriting existing method TeamLocation.near.
#                        root        /                                                      {:controller=>"protips", :action=>"index"}
#                     welcome        /welcome(.:format)                                     {:action=>"index", :controller=>"home"}
#                                    /fonts                                                 {:to=>#<Sinatra::ShowExceptions:0x00000101cb1a40 @app=#<Rack::Head:0x00000101cb1a68 @app=#<ServeFonts:0x00000101cb1b80 @app=nil, @template_cache=#<Tilt::Cache:0x00000101cb1b58 @cache={}>>>, @template=#<ERB:0x00000101cb1a18 @safe_level=nil, @src="#coding:UTF-8\n_erbout = ''; _erbout.concat \"<!DOCTYPE html>\\n<html>\\n<head>\\n  <meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\"/>\\n  <title>\"\n\n\n\n; _erbout.concat((h exception.class ).to_s); _erbout.concat \" at \"; _erbout.concat((h path ).to_s); _erbout.concat \"</title>\\n\\n  <script type=\\\"text/javascript\\\">\\n  //<!--\\n  function toggle(id) {\\n    var pre  = document.getElementById(\\\"pre-\\\" + id);\\n    var post = document.getElementById(\\\"post-\\\" + id);\\n    var context = document.getElementById(\\\"context-\\\" + id);\\n\\n    if (pre.style.display == 'block') {\\n      pre.style.display = 'none';\\n      post.style.display = 'none';\\n      context.style.background = \\\"none\\\";\\n    } else {\\n      pre.style.display = 'block';\\n      post.style.display = 'block';\\n      context.style.background = \\\"#fffed9\\\";\\n    }\\n  }\\n\\n  function toggleBacktrace(){\\n    var bt = document.getElementById(\\\"backtrace\\\");\\n    var toggler = document.getElementById(\\\"expando\\\");\\n\\n    if (bt.className == 'condensed') {\\n      bt.className = 'expanded';\\n      toggler.innerHTML = \\\"(condense)\\\";\\n    } else {\\n      bt.className = 'condensed';\\n      toggler.innerHTML = \\\"(expand)\\\";\\n    }\\n  }\\n  //-->\\n  </script>\\n\\n<style type=\\\"text/css\\\" media=\\\"screen\\\">\\n  *                   {margin: 0; padding: 0; border: 0; outline: 0;}\\n  div.clear           {clear: both;}\\n  body                {background: #EEEEEE; margin: 0; padding: 0;\\n                       font-family: 'Lucida Grande', 'Lucida Sans Unicode',\\n                       'Garuda';}\\n  code                {font-family: 'Lucida Console', monospace;\\n                       font-size: 12px;}\\n  li                  {height: 18px;}\\n  ul                  {list-style: none; margin: 0; padding: 0;}\\n  ol:hover            {cursor: pointer;}\\n  ol li               {white-space: pre;}\\n  #explanation        {font-size: 12px; color: #666666;\\n                       margin: 20px 0 0 100px;}\\n/* WRAP */\\n  #wrap               {width: 1000px; background: #FFFFFF; margin: 0 auto;\\n                       padding: 30px 50px 20px 50px;\\n                       border-left: 1px solid #DDDDDD;\\n                       border-right: 1px solid #DDDDDD;}\\n/* HEADER */\\n  #header             {margin: 0 auto 25px auto;}\\n  #header img         {float: left;}\\n  #header #summary    {float: left; margin: 12px 0 0 20px; width:660px;\\n                       font-family: 'Lucida Grande', 'Lucida Sans Unicode';}\\n  h1                  {margin: 0; font-size: 36px; color: #981919;}\\n  h2                  {margin: 0; font-size: 22px; color: #333333;}\\n  #header ul          {margin: 0; font-size: 12px; color: #666666;}\\n  #header ul li strong{color: #444444;}\\n  #header ul li       {display: inline; padding: 0 10px;}\\n  #header ul li.first {padding-left: 0;}\\n  #header ul li.last  {border: 0; padding-right: 0;}\\n/* BODY */\\n  #backtrace,\\n  #get,\\n  #post,\\n  #cookies,\\n  #rack               {width: 980px; margin: 0 auto 10px auto;}\\n  p#nav               {float: right; font-size: 14px;}\\n/* BACKTRACE */\\n  a#expando           {float: left; padding-left: 5px; color: #666666;\\n                      font-size: 14px; text-decoration: none; cursor: pointer;}\\n  a#expando:hover     {text-decoration: underline;}\\n  h3                  {float: left; width: 100px; margin-bottom: 10px;\\n                       color: #981919; font-size: 14px; font-weight: bold;}\\n  #nav a              {color: #666666; text-decoration: none; padding: 0 5px;}\\n  #backtrace li.frame-info {background: #f7f7f7; padding-left: 10px;\\n                           font-size: 12px; color: #333333;}\\n  #backtrace ul       {list-style-position: outside; border: 1px solid #E9E9E9;\\n                       border-bottom: 0;}\\n  #backtrace ol       {width: 920px; margin-left: 50px;\\n                       font: 10px 'Lucida Console', monospace; color: #666666;}\\n  #backtrace ol li    {border: 0; border-left: 1px solid #E9E9E9;\\n                       padding: 2px 0;}\\n  #backtrace ol code  {font-size: 10px; color: #555555; padding-left: 5px;}\\n  #backtrace-ul li    {border-bottom: 1px solid #E9E9E9; height: auto;\\n                       padding: 3px 0;}\\n  #backtrace-ul .code {padding: 6px 0 4px 0;}\\n  #backtrace.condensed .system,\\n  #backtrace.condensed .framework {display:none;}\\n/* REQUEST DATA */\\n  p.no-data           {padding-top: 2px; font-size: 12px; color: #666666;}\\n  table.req           {width: 980px; text-align: left; font-size: 12px;\\n                       color: #666666; padding: 0; border-spacing: 0;\\n                       border: 1px solid #EEEEEE; border-bottom: 0;\\n                       border-left: 0;\\n                       clear:both}\\n  table.req tr th     {padding: 2px 10px; font-weight: bold;\\n                       background: #F7F7F7; border-bottom: 1px solid #EEEEEE;\\n                       border-left: 1px solid #EEEEEE;}\\n  table.req tr td     {padding: 2px 20px 2px 10px;\\n                       border-bottom: 1px solid #EEEEEE;\\n                       border-left: 1px solid #EEEEEE;}\\n/* HIDE PRE/POST CODE AT START */\\n  .pre-context,\\n  .post-context       {display: none;}\\n\\n  table td.code       {width:750px}\\n  table td.code div   {width:750px;overflow:hidden}\\n</style>\\n</head>\\n<body>\\n  <div id=\\\"wrap\\\">\\n    <div id=\\\"header\\\">\\n      <img src=\\\"\"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n; _erbout.concat(( env['SCRIPT_NAME'] ).to_s); _erbout.concat \"/__sinatra__/500.png\\\" alt=\\\"application error\\\" height=\\\"161\\\" width=\\\"313\\\" />\\n      <div id=\\\"summary\\\">\\n        <h1><strong>\"\n\n; _erbout.concat((h exception.class ).to_s); _erbout.concat \"</strong> at <strong>\"; _erbout.concat((h path ).to_s); _erbout.concat \"\\n          </strong></h1>\\n        <h2>\"\n\n; _erbout.concat((h exception.message ).to_s); _erbout.concat \"</h2>\\n        <ul>\\n          <li class=\\\"first\\\"><strong>file:</strong> <code>\\n            \"\n\n\n; _erbout.concat((h frames.first.filename.split(\"/\").last ).to_s); _erbout.concat \"</code></li>\\n          <li><strong>location:</strong> <code>\"\n; _erbout.concat((h frames.first.function ).to_s); _erbout.concat \"\\n            </code></li>\\n          <li class=\\\"last\\\"><strong>line:\\n            </strong> \"\n\n\n; _erbout.concat((h frames.first.lineno ).to_s); _erbout.concat \"</li>\\n        </ul>\\n      </div>\\n      <div class=\\\"clear\\\"></div>\\n    </div>\\n\\n    <div id=\\\"backtrace\\\" class='condensed'>\\n      <h3>BACKTRACE</h3>\\n      <p><a href=\\\"#\\\" id=\\\"expando\\\"\\n            onclick=\\\"toggleBacktrace(); return false\\\">(expand)</a></p>\\n      <p id=\\\"nav\\\"><strong>JUMP TO:</strong>\\n         <a href=\\\"#get-info\\\">GET</a>\\n         <a href=\\\"#post-info\\\">POST</a>\\n         <a href=\\\"#cookie-info\\\">COOKIES</a>\\n         <a href=\\\"#env-info\\\">ENV</a>\\n      </p>\\n      <div class=\\\"clear\\\"></div>\\n\\n      <ul id=\\\"backtrace-ul\\\">\\n\\n      \"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n;  id = 1 ; _erbout.concat \"\\n      \"\n;  frames.each do |frame| ; _erbout.concat \"\\n          \"\n;  if frame.context_line && frame.context_line != \"#\" ; _erbout.concat \"\\n\\n            <li class=\\\"frame-info \"\n\n; _erbout.concat(( frame_class(frame) ).to_s); _erbout.concat \"\\\">\\n              <code>\"\n; _erbout.concat((h frame.filename ).to_s); _erbout.concat \"</code> in\\n                <code><strong>\"\n; _erbout.concat((h frame.function ).to_s); _erbout.concat \"</strong></code>\\n            </li>\\n\\n            <li class=\\\"code \"\n\n\n; _erbout.concat(( frame_class(frame) ).to_s); _erbout.concat \"\\\">\\n              \"\n;  if frame.pre_context ; _erbout.concat \"\\n              <ol start=\\\"\"\n; _erbout.concat((h frame.pre_context_lineno + 1 ).to_s); _erbout.concat \"\\\"\\n                  class=\\\"pre-context\\\" id=\\\"pre-\"\n; _erbout.concat(( id ).to_s); _erbout.concat \"\\\"\\n                  onclick=\\\"toggle(\"\n; _erbout.concat(( id ).to_s); _erbout.concat \");\\\">\\n                \"\n;  frame.pre_context.each do |line| ; _erbout.concat \"\\n                <li class=\\\"pre-context-line\\\"><code>\"\n; _erbout.concat((h line ).to_s); _erbout.concat \"</code></li>\\n                \"\n;  end ; _erbout.concat \"\\n              </ol>\\n              \"\n\n;  end ; _erbout.concat \"\\n\\n              <ol start=\\\"\"\n\n; _erbout.concat(( frame.lineno ).to_s); _erbout.concat \"\\\" class=\\\"context\\\" id=\\\"\"; _erbout.concat(( id ).to_s); _erbout.concat \"\\\"\\n                  onclick=\\\"toggle(\"\n; _erbout.concat(( id ).to_s); _erbout.concat \");\\\">\\n                <li class=\\\"context-line\\\" id=\\\"context-\"\n; _erbout.concat(( id ).to_s); _erbout.concat \"\\\"><code>\"; _erbout.concat((\n                  h frame.context_line ).to_s); _erbout.concat \"</code></li>\\n              </ol>\\n\\n              \"\n\n\n;  if frame.post_context ; _erbout.concat \"\\n              <ol start=\\\"\"\n; _erbout.concat((h frame.lineno + 1 ).to_s); _erbout.concat \"\\\" class=\\\"post-context\\\"\\n                  id=\\\"post-\"\n; _erbout.concat(( id ).to_s); _erbout.concat \"\\\" onclick=\\\"toggle(\"; _erbout.concat(( id ).to_s); _erbout.concat \");\\\">\\n                \"\n;  frame.post_context.each do |line| ; _erbout.concat \"\\n                <li class=\\\"post-context-line\\\"><code>\"\n; _erbout.concat((h line ).to_s); _erbout.concat \"</code></li>\\n                \"\n;  end ; _erbout.concat \"\\n              </ol>\\n              \"\n\n;  end ; _erbout.concat \"\\n              <div class=\\\"clear\\\"></div>\\n            </li>\\n\\n          \"\n\n\n\n;  end ; _erbout.concat \"\\n\\n        \"\n\n;  id += 1 ; _erbout.concat \"\\n      \"\n;  end ; _erbout.concat \"\\n\\n      </ul>\\n    </div> <!-- /BACKTRACE -->\\n\\n    <div id=\\\"get\\\">\\n      <h3 id=\\\"get-info\\\">GET</h3>\\n      \"\n\n\n\n\n\n\n;  unless req.GET.empty? ; _erbout.concat \"\\n        <table class=\\\"req\\\">\\n          <tr>\\n            <th>Variable</th>\\n            <th>Value</th>\\n          </tr>\\n           \"\n\n\n\n\n\n;  req.GET.sort_by { |k, v| k.to_s }.each { |key, val| ; _erbout.concat \"\\n          <tr>\\n            <td>\"\n\n; _erbout.concat((h key ).to_s); _erbout.concat \"</td>\\n            <td class=\\\"code\\\"><div>\"\n; _erbout.concat((h val.inspect ).to_s); _erbout.concat \"</div></td>\\n          </tr>\\n          \"\n\n;  } ; _erbout.concat \"\\n        </table>\\n      \"\n\n;  else ; _erbout.concat \"\\n        <p class=\\\"no-data\\\">No GET data.</p>\\n      \"\n\n;  end ; _erbout.concat \"\\n      <div class=\\\"clear\\\"></div>\\n    </div> <!-- /GET -->\\n\\n    <div id=\\\"post\\\">\\n      <h3 id=\\\"post-info\\\">POST</h3>\\n      \"\n\n\n\n\n\n;  unless req.POST.empty? ; _erbout.concat \"\\n        <table class=\\\"req\\\">\\n          <tr>\\n            <th>Variable</th>\\n            <th>Value</th>\\n          </tr>\\n          \"\n\n\n\n\n\n;  req.POST.sort_by { |k, v| k.to_s }.each { |key, val| ; _erbout.concat \"\\n          <tr>\\n            <td>\"\n\n; _erbout.concat((h key ).to_s); _erbout.concat \"</td>\\n            <td class=\\\"code\\\"><div>\"\n; _erbout.concat((h val.inspect ).to_s); _erbout.concat \"</div></td>\\n          </tr>\\n          \"\n\n;  } ; _erbout.concat \"\\n        </table>\\n      \"\n\n;  else ; _erbout.concat \"\\n        <p class=\\\"no-data\\\">No POST data.</p>\\n      \"\n\n;  end ; _erbout.concat \"\\n      <div class=\\\"clear\\\"></div>\\n    </div> <!-- /POST -->\\n\\n    <div id=\\\"cookies\\\">\\n      <h3 id=\\\"cookie-info\\\">COOKIES</h3>\\n      \"\n\n\n\n\n\n;  unless req.cookies.empty? ; _erbout.concat \"\\n        <table class=\\\"req\\\">\\n          <tr>\\n            <th>Variable</th>\\n            <th>Value</th>\\n          </tr>\\n          \"\n\n\n\n\n\n;  req.cookies.each { |key, val| ; _erbout.concat \"\\n            <tr>\\n              <td>\"\n\n; _erbout.concat((h key ).to_s); _erbout.concat \"</td>\\n              <td class=\\\"code\\\"><div>\"\n; _erbout.concat((h val.inspect ).to_s); _erbout.concat \"</div></td>\\n            </tr>\\n          \"\n\n;  } ; _erbout.concat \"\\n        </table>\\n      \"\n\n;  else ; _erbout.concat \"\\n        <p class=\\\"no-data\\\">No cookie data.</p>\\n      \"\n\n;  end ; _erbout.concat \"\\n      <div class=\\\"clear\\\"></div>\\n    </div> <!-- /COOKIES -->\\n\\n    <div id=\\\"rack\\\">\\n      <h3 id=\\\"env-info\\\">Rack ENV</h3>\\n      <table class=\\\"req\\\">\\n        <tr>\\n          <th>Variable</th>\\n          <th>Value</th>\\n        </tr>\\n         \"\n\n\n\n\n\n\n\n\n\n\n;  env.sort_by { |k, v| k.to_s }.each { |key, val| ; _erbout.concat \"\\n         <tr>\\n           <td>\"\n\n; _erbout.concat((h key ).to_s); _erbout.concat \"</td>\\n           <td class=\\\"code\\\"><div>\"\n; _erbout.concat((h val ).to_s); _erbout.concat \"</div></td>\\n         </tr>\\n         \"\n\n;  } ; _erbout.concat \"\\n      </table>\\n      <div class=\\\"clear\\\"></div>\\n    </div> <!-- /RACK ENV -->\\n\\n    <p id=\\\"explanation\\\">You're seeing this error because you have\\nenabled the <code>show_exceptions</code> setting.</p>\\n  </div> <!-- /WRAP -->\\n  </body>\\n</html>\\n\"\n\n\n\n\n\n\n\n\n\n; _erbout.force_encoding(__ENCODING__)", @enc=#<Encoding:UTF-8>, @filename=nil>>}
#                    p_dpvbbg        /p/dpvbbg(.:format)                                    {:to=>#<Proc:0x0000010abb2230@/Users/mike/.rvm/gems/ruby-2.1.0@coderwall/gems/actionpack-3.1.4/lib/action_dispatch/routing/redirection.rb:85 (lambda)>}
#                          gh        /gh(.:format)                                          {:to=>#<Proc:0x0000010abbb010@/Users/mike/.rvm/gems/ruby-2.1.0@coderwall/gems/actionpack-3.1.4/lib/action_dispatch/routing/redirection.rb:85 (lambda)>}
#             latest_comments        /comments(.:format)                                    {:controller=>"comments", :action=>"index"}
#                        jobs        /jobs(/:location(/:skill))(.:format)                   {:controller=>"opportunities", :action=>"index"}
#                    jobs_map        /jobs-map(.:format)                                    {:controller=>"opportunities", :action=>"map"}
#             split_dashboard        /split                                                 {:action=>"split", :to=>Split::Dashboard}
#              random_protips GET    /p/random(.:format)                                    {:action=>"random", :controller=>"protips"}
#              search_protips GET    /p/search(.:format)                                    {:action=>"search", :controller=>"protips"}
#                             POST   /p/search(.:format)                                    {:action=>"search", :controller=>"protips"}
#                  my_protips GET    /p/me(.:format)                                        {:action=>"me", :controller=>"protips"}
#          reviewable_protips GET    /p/admin(.:format)                                     {:action=>"admin", :controller=>"protips"}
#                team_protips GET    /p/team/:team_slug(.:format)                           {:controller=>"protips", :action=>"team"}
#                date_protips GET    /p/d/:date(/:start)(.:format)                          {:controller=>"protips", :action=>"date"}
#     trending_topics_protips GET    /p/t/trending(.:format)                                {:controller=>"protips", :action=>"trending"}
#             by_tags_protips GET    /p/t/by_tags(.:format)                                 {:controller=>"protips", :action=>"by_tags"}
#                user_protips GET    /p/u/:username(.:format)                               {:controller=>"protips", :action=>"user"}
#              tagged_protips GET    /p/t(/*tags)(.:format)                                 {:controller=>"networks", :action=>"tag"}
#           subscribe_protips PUT    /p/t(/*tags)/subscribe(.:format)                       {:controller=>"protips", :action=>"subscribe"}
#         unsubscribe_protips PUT    /p/t(/*tags)/unsubscribe(.:format)                     {:controller=>"protips", :action=>"unsubscribe"}
#               fresh_protips GET    /p/fresh(.:format)                                     {:action=>"fresh", :controller=>"protips"}
#            trending_protips GET    /p/trending(.:format)                                  {:action=>"trending", :controller=>"protips"}
#             popular_protips GET    /p/popular(.:format)                                   {:action=>"popular", :controller=>"protips"}
#               liked_protips GET    /p/liked(.:format)                                     {:action=>"liked", :controller=>"protips"}
#             preview_protips POST   /p/preview(.:format)                                   {:action=>"preview", :controller=>"protips"}
#               upvote_protip POST   /p/:id/upvote(.:format)                                {:id=>/[\dA-Z\-_]{6}/i, :action=>"upvote", :controller=>"protips"}
#                  tag_protip POST   /p/:id/tag(.:format)                                   {:id=>/[\dA-Z\-_]{6}/i, :action=>"tag", :controller=>"protips"}
#                 flag_protip POST   /p/:id/flag(.:format)                                  {:id=>/[\dA-Z\-_]{6}/i, :action=>"flag", :controller=>"protips"}
#              feature_protip POST   /p/:id/feature(.:format)                               {:id=>/[\dA-Z\-_]{6}/i, :action=>"feature", :controller=>"protips"}
#                queue_protip POST   /p/:id/queue/:queue(.:format)                          {:id=>/[\dA-Z\-_]{6}/i, :controller=>"protips", :action=>"queue"}
#           delete_tag_protip POST   /p/:id/delete_tag/:topic(.:format)                     {:id=>/[\dA-Z\-_]{6}/i, :topic=>/[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/, :controller=>"protips", :action=>"delete_tag"}
#         like_protip_comment POST   /p/:protip_id/comments/:id/like(.:format)              {:id=>/\d+/, :protip_id=>/[\dA-Z\-_]{6}/i, :action=>"like", :controller=>"comments"}
#             protip_comments GET    /p/:protip_id/comments(.:format)                       {:protip_id=>/[\dA-Z\-_]{6}/i, :action=>"index", :controller=>"comments"}
#                             POST   /p/:protip_id/comments(.:format)                       {:protip_id=>/[\dA-Z\-_]{6}/i, :action=>"create", :controller=>"comments"}
#          new_protip_comment GET    /p/:protip_id/comments/new(.:format)                   {:protip_id=>/[\dA-Z\-_]{6}/i, :action=>"new", :controller=>"comments"}
#         edit_protip_comment GET    /p/:protip_id/comments/:id/edit(.:format)              {:id=>/\d+/, :protip_id=>/[\dA-Z\-_]{6}/i, :action=>"edit", :controller=>"comments"}
#              protip_comment GET    /p/:protip_id/comments/:id(.:format)                   {:id=>/\d+/, :protip_id=>/[\dA-Z\-_]{6}/i, :action=>"show", :controller=>"comments"}
#                             PUT    /p/:protip_id/comments/:id(.:format)                   {:id=>/\d+/, :protip_id=>/[\dA-Z\-_]{6}/i, :action=>"update", :controller=>"comments"}
#                             DELETE /p/:protip_id/comments/:id(.:format)                   {:id=>/\d+/, :protip_id=>/[\dA-Z\-_]{6}/i, :action=>"destroy", :controller=>"comments"}
#                     protips GET    /p(.:format)                                           {:action=>"index", :controller=>"protips"}
#                             POST   /p(.:format)                                           {:action=>"create", :controller=>"protips"}
#                  new_protip GET    /p/new(.:format)                                       {:action=>"new", :controller=>"protips"}
#                 edit_protip GET    /p/:id/edit(.:format)                                  {:id=>/[\dA-Z\-_]{6}/i, :action=>"edit", :controller=>"protips"}
#                      protip GET    /p/:id(.:format)                                       {:id=>/[\dA-Z\-_]{6}/i, :action=>"show", :controller=>"protips"}
#                             PUT    /p/:id(.:format)                                       {:id=>/[\dA-Z\-_]{6}/i, :action=>"update", :controller=>"protips"}
#                             DELETE /p/:id(.:format)                                       {:id=>/[\dA-Z\-_]{6}/i, :action=>"destroy", :controller=>"protips"}
#           featured_networks GET    /n/featured(.:format)                                  {:action=>"featured", :controller=>"networks"}
#               user_networks GET    /n/u/:username(.:format)                               {:controller=>"networks", :action=>"user"}
#              tagged_network GET    /n/:id/t(/*tags)(.:format)                             {:controller=>"networks", :action=>"tag"}
#             members_network GET    /n/:id/members(.:format)                               {:controller=>"networks", :action=>"members"}
#               mayor_network GET    /n/:id/mayor(.:format)                                 {:controller=>"networks", :action=>"mayor"}
#              expert_network GET    /n/:id/expert(.:format)                                {:controller=>"networks", :action=>"expert"}
#                join_network POST   /n/:id/join(.:format)                                  {:controller=>"networks", :action=>"join"}
#               leave_network POST   /n/:id/leave(.:format)                                 {:controller=>"networks", :action=>"leave"}
#         update_tags_network POST   /n/:id/update-tags(.:format)                           {:controller=>"networks", :action=>"update_tags"}
#       current_mayor_network GET    /n/:id/current-mayor(.:format)                         {:controller=>"networks", :action=>"current_mayor"}
#                    networks GET    /n(.:format)                                           {:action=>"index", :controller=>"networks"}
#                             POST   /n(.:format)                                           {:action=>"create", :controller=>"networks"}
#                 new_network GET    /n/new(.:format)                                       {:action=>"new", :controller=>"networks"}
#                edit_network GET    /n/:id/edit(.:format)                                  {:action=>"edit", :controller=>"networks"}
#                     network GET    /n/:id(.:format)                                       {:action=>"show", :controller=>"networks"}
#                             PUT    /n/:id(.:format)                                       {:action=>"update", :controller=>"networks"}
#                             DELETE /n/:id(.:format)                                       {:action=>"destroy", :controller=>"networks"}
#    dequeue_processing_queue POST   /q/:id/dequeue/:item(.:format)                         {:controller=>"processing_queues", :action=>"dequeue"}
#           processing_queues GET    /q(.:format)                                           {:action=>"index", :controller=>"processing_queues"}
#                             POST   /q(.:format)                                           {:action=>"create", :controller=>"processing_queues"}
#        new_processing_queue GET    /q/new(.:format)                                       {:action=>"new", :controller=>"processing_queues"}
#       edit_processing_queue GET    /q/:id/edit(.:format)                                  {:action=>"edit", :controller=>"processing_queues"}
#            processing_queue GET    /q/:id(.:format)                                       {:action=>"show", :controller=>"processing_queues"}
#                             PUT    /q/:id(.:format)                                       {:action=>"update", :controller=>"processing_queues"}
#                             DELETE /q/:id(.:format)                                       {:action=>"destroy", :controller=>"processing_queues"}
#                     protips        /trending(.:format)                                    {:action=>"index", :controller=>"protips"}
#       letter_opener_letters        /letter_opener(.:format)                               {:controller=>"letter_opener/letters", :action=>"index"}
#        letter_opener_letter        /letter_opener/:id/:style.html(.:format)               {:controller=>"letter_opener/letters", :action=>"show"}
#                                    /campaigns                                             {:action=>"campaigns", :to=>Campaigns::Preview}
#                                    /mail                                                  {:action=>"mail", :to=>Notifier::Preview}
#                                    /digest                                                {:action=>"digest", :to=>WeeklyDigest::Preview}
#                                    /subscription                                          {:action=>"subscription", :to=>Subscription::Preview}
#                         faq        /faq(.:format)                                         {:action=>"show", :controller=>"pages"}
#                         tos        /tos(.:format)                                         {:action=>"show", :controller=>"pages"}
#              privacy_policy        /privacy_policy(.:format)                              {:action=>"show", :controller=>"pages"}
#                  contact_us        /contact_us(.:format)                                  {:action=>"show", :controller=>"pages"}
#                         api        /api(.:format)                                         {:action=>"show", :controller=>"pages"}
#                achievements        /achievements(.:format)                                {:action=>"show", :controller=>"pages"}
#                                    /pages/:page(.:format)                                 {:controller=>"pages", :action=>"show"}
#                 award_badge        /award(.:format)                                       {:action=>"award", :controller=>"achievements"}
#                authenticate        /auth/:provider/callback(.:format)                     {:controller=>"sessions", :action=>"create"}
#      authentication_failure        /auth/failure(.:format)                                {:controller=>"sessions", :action=>"failure"}
#                    settings        /settings(.:format)                                    {:controller=>"users", :action=>"edit"}
#                                    /redeem/:code(.:format)                                {:controller=>"redemptions", :action=>"show"}
#                 unsubscribe        /unsubscribe(.:format)                                 {:controller=>"emails", :action=>"unsubscribe"}
#                   delivered        /delivered(.:format)                                   {:controller=>"emails", :action=>"delivered"}
#              delete_account        /delete_account(.:format)                              {:controller=>"users", :action=>"delete_account"}
#    delete_account_confirmed POST   /delete_account_confirmed(.:format)                    {:controller=>"users", :action=>"delete_account_confirmed"}
#             authentications GET    /authentications(.:format)                             {:action=>"index", :controller=>"authentications"}
#                             POST   /authentications(.:format)                             {:action=>"create", :controller=>"authentications"}
#          new_authentication GET    /authentications/new(.:format)                         {:action=>"new", :controller=>"authentications"}
#         edit_authentication GET    /authentications/:id/edit(.:format)                    {:action=>"edit", :controller=>"authentications"}
#              authentication GET    /authentications/:id(.:format)                         {:action=>"show", :controller=>"authentications"}
#                             PUT    /authentications/:id(.:format)                         {:action=>"update", :controller=>"authentications"}
#                             DELETE /authentications/:id(.:format)                         {:action=>"destroy", :controller=>"authentications"}
#                   usernames GET    /usernames(.:format)                                   {:action=>"index", :controller=>"usernames"}
#                             POST   /usernames(.:format)                                   {:action=>"create", :controller=>"usernames"}
#                new_username GET    /usernames/new(.:format)                               {:action=>"new", :controller=>"usernames"}
#               edit_username GET    /usernames/:id/edit(.:format)                          {:action=>"edit", :controller=>"usernames"}
#                    username GET    /usernames/:id(.:format)                               {:action=>"show", :controller=>"usernames"}
#                             PUT    /usernames/:id(.:format)                               {:action=>"update", :controller=>"usernames"}
#                             DELETE /usernames/:id(.:format)                               {:action=>"destroy", :controller=>"usernames"}
#                 invitations GET    /invitations(.:format)                                 {:action=>"index", :controller=>"invitations"}
#                             POST   /invitations(.:format)                                 {:action=>"create", :controller=>"invitations"}
#              new_invitation GET    /invitations/new(.:format)                             {:action=>"new", :controller=>"invitations"}
#             edit_invitation GET    /invitations/:id/edit(.:format)                        {:action=>"edit", :controller=>"invitations"}
#                  invitation GET    /invitations/:id(.:format)                             {:action=>"show", :controller=>"invitations"}
#                             PUT    /invitations/:id(.:format)                             {:action=>"update", :controller=>"invitations"}
#                             DELETE /invitations/:id(.:format)                             {:action=>"destroy", :controller=>"invitations"}
#                  invitation        /i/:id/:r(.:format)                                    {:controller=>"invitations", :action=>"show"}
#              force_sessions GET    /sessions/force(.:format)                              {:action=>"force", :controller=>"sessions"}
#                    sessions GET    /sessions(.:format)                                    {:action=>"index", :controller=>"sessions"}
#                             POST   /sessions(.:format)                                    {:action=>"create", :controller=>"sessions"}
#                 new_session GET    /sessions/new(.:format)                                {:action=>"new", :controller=>"sessions"}
#                edit_session GET    /sessions/:id/edit(.:format)                           {:action=>"edit", :controller=>"sessions"}
#                     session GET    /sessions/:id(.:format)                                {:action=>"show", :controller=>"sessions"}
#                             PUT    /sessions/:id(.:format)                                {:action=>"update", :controller=>"sessions"}
#                             DELETE /sessions/:id(.:format)                                {:action=>"destroy", :controller=>"sessions"}
#             webhooks_stripe        /webhooks/stripe(.:format)                             {:controller=>"accounts", :action=>"webhook"}
#                      alerts POST   /alerts(.:format)                                      {:controller=>"alerts", :action=>"create"}
#                             GET    /alerts(.:format)                                      {:controller=>"alerts", :action=>"index"}
#                 follow_user POST   /users/:username/follow(.:format)                      {:controller=>"follows", :action=>"create"}
#                    teamname        /team/:slug(.:format)                                  {:controller=>"teams", :action=>"show"}
#               teamname_edit        /team/:slug/edit(.:format)                             {:controller=>"teams", :action=>"edit"}
#                         job        /team/:slug(/:job_id)(.:format)                        {:controller=>"teams", :action=>"show"}
#               inquiry_teams POST   /teams/inquiry(.:format)                               {:action=>"inquiry", :controller=>"teams"}
#                 accept_team GET    /teams/:id/accept(.:format)                            {:action=>"accept", :controller=>"teams"}
#            record_exit_team POST   /teams/:id/record-exit(.:format)                       {:controller=>"teams", :action=>"record_exit"}
#               visitors_team GET    /teams/:id/visitors(.:format)                          {:action=>"visitors", :controller=>"teams"}
#                 follow_team POST   /teams/:id/follow(.:format)                            {:action=>"create", :controller=>"follows"}
#                   join_team POST   /teams/:id/join(.:format)                              {:action=>"join", :controller=>"teams"}
#           approve_join_team POST   /teams/:id/join/:user_id/approve(.:format)             {:controller=>"teams", :action=>"approve_join"}
#              deny_join_team POST   /teams/:id/join/:user_id/deny(.:format)                {:controller=>"teams", :action=>"deny_join"}
#              followed_teams GET    /teams/followed(.:format)                              {:action=>"followed", :controller=>"teams"}
#                search_teams GET    /teams/search(.:format)                                {:action=>"search", :controller=>"teams"}
#           team_team_members GET    /teams/:team_id/team_members(.:format)                 {:action=>"index", :controller=>"team_members"}
#                             POST   /teams/:team_id/team_members(.:format)                 {:action=>"create", :controller=>"team_members"}
#        new_team_team_member GET    /teams/:team_id/team_members/new(.:format)             {:action=>"new", :controller=>"team_members"}
#       edit_team_team_member GET    /teams/:team_id/team_members/:id/edit(.:format)        {:action=>"edit", :controller=>"team_members"}
#            team_team_member GET    /teams/:team_id/team_members/:id(.:format)             {:action=>"show", :controller=>"team_members"}
#                             PUT    /teams/:team_id/team_members/:id(.:format)             {:action=>"update", :controller=>"team_members"}
#                             DELETE /teams/:team_id/team_members/:id(.:format)             {:action=>"destroy", :controller=>"team_members"}
#              team_locations GET    /teams/:team_id/team_locations(.:format)               {:action=>"index", :controller=>"team_locations"}
#                             POST   /teams/:team_id/team_locations(.:format)               {:action=>"create", :controller=>"team_locations"}
#           new_team_location GET    /teams/:team_id/team_locations/new(.:format)           {:action=>"new", :controller=>"team_locations"}
#          edit_team_location GET    /teams/:team_id/team_locations/:id/edit(.:format)      {:action=>"edit", :controller=>"team_locations"}
#               team_location GET    /teams/:team_id/team_locations/:id(.:format)           {:action=>"show", :controller=>"team_locations"}
#                             PUT    /teams/:team_id/team_locations/:id(.:format)           {:action=>"update", :controller=>"team_locations"}
#                             DELETE /teams/:team_id/team_locations/:id(.:format)           {:action=>"destroy", :controller=>"team_locations"}
#      apply_team_opportunity POST   /teams/:team_id/opportunities/:id/apply(.:format)      {:action=>"apply", :controller=>"opportunities"}
#   activate_team_opportunity GET    /teams/:team_id/opportunities/:id/activate(.:format)   {:action=>"activate", :controller=>"opportunities"}
# deactivate_team_opportunity GET    /teams/:team_id/opportunities/:id/deactivate(.:format) {:action=>"deactivate", :controller=>"opportunities"}
#      visit_team_opportunity POST   /teams/:team_id/opportunities/:id/visit(.:format)      {:action=>"visit", :controller=>"opportunities"}
#          team_opportunities GET    /teams/:team_id/opportunities(.:format)                {:action=>"index", :controller=>"opportunities"}
#                             POST   /teams/:team_id/opportunities(.:format)                {:action=>"create", :controller=>"opportunities"}
#        new_team_opportunity GET    /teams/:team_id/opportunities/new(.:format)            {:action=>"new", :controller=>"opportunities"}
#       edit_team_opportunity GET    /teams/:team_id/opportunities/:id/edit(.:format)       {:action=>"edit", :controller=>"opportunities"}
#            team_opportunity GET    /teams/:team_id/opportunities/:id(.:format)            {:action=>"show", :controller=>"opportunities"}
#                             PUT    /teams/:team_id/opportunities/:id(.:format)            {:action=>"update", :controller=>"opportunities"}
#                             DELETE /teams/:team_id/opportunities/:id(.:format)            {:action=>"destroy", :controller=>"opportunities"}
#   send_invoice_team_account POST   /teams/:team_id/account/send_invoice(.:format)         {:action=>"send_invoice", :controller=>"accounts"}
#                team_account POST   /teams/:team_id/account(.:format)                      {:action=>"create", :controller=>"accounts"}
#            new_team_account GET    /teams/:team_id/account/new(.:format)                  {:action=>"new", :controller=>"accounts"}
#           edit_team_account GET    /teams/:team_id/account/edit(.:format)                 {:action=>"edit", :controller=>"accounts"}
#                             GET    /teams/:team_id/account(.:format)                      {:action=>"show", :controller=>"accounts"}
#                             PUT    /teams/:team_id/account(.:format)                      {:action=>"update", :controller=>"accounts"}
#                             DELETE /teams/:team_id/account(.:format)                      {:action=>"destroy", :controller=>"accounts"}
#                       teams GET    /teams(.:format)                                       {:action=>"index", :controller=>"teams"}
#                             POST   /teams(.:format)                                       {:action=>"create", :controller=>"teams"}
#                    new_team GET    /teams/new(.:format)                                   {:action=>"new", :controller=>"teams"}
#                   edit_team GET    /teams/:id/edit(.:format)                              {:action=>"edit", :controller=>"teams"}
#                        team GET    /teams/:id(.:format)                                   {:action=>"show", :controller=>"teams"}
#                             PUT    /teams/:id(.:format)                                   {:action=>"update", :controller=>"teams"}
#                             DELETE /teams/:id(.:format)                                   {:action=>"destroy", :controller=>"teams"}
#                 leaderboard        /leaderboard(.:format)                                 {:controller=>"teams", :action=>"leaderboard"}
#                   employers        /employers(.:format)                                   {:controller=>"teams", :action=>"upgrade"}
#               unlink_github POST   /github/unlink(.:format)                               {:controller=>"users", :action=>"unlink_provider"}
#                                    /github/:username(.:format)                            {:controller=>"users", :action=>"show"}
#              unlink_twitter POST   /twitter/unlink(.:format)                              {:controller=>"users", :action=>"unlink_provider"}
#                                    /twitter/:username(.:format)                           {:controller=>"users", :action=>"show"}
#               unlink_forrst POST   /forrst/unlink(.:format)                               {:controller=>"users", :action=>"unlink_provider"}
#                                    /forrst/:username(.:format)                            {:controller=>"users", :action=>"show"}
#             unlink_dribbble POST   /dribbble/unlink(.:format)                             {:controller=>"users", :action=>"unlink_provider"}
#                                    /dribbble/:username(.:format)                          {:controller=>"users", :action=>"show"}
#             unlink_linkedin POST   /linkedin/unlink(.:format)                             {:controller=>"users", :action=>"unlink_provider"}
#                                    /linkedin/:username(.:format)                          {:controller=>"users", :action=>"show"}
#             unlink_codeplex POST   /codeplex/unlink(.:format)                             {:controller=>"users", :action=>"unlink_provider"}
#                                    /codeplex/:username(.:format)                          {:controller=>"users", :action=>"show"}
#            unlink_bitbucket POST   /bitbucket/unlink(.:format)                            {:controller=>"users", :action=>"unlink_provider"}
#                                    /bitbucket/:username(.:format)                         {:controller=>"users", :action=>"show"}
#        unlink_stackoverflow POST   /stackoverflow/unlink(.:format)                        {:controller=>"users", :action=>"unlink_provider"}
#                                    /stackoverflow/:username(.:format)                     {:controller=>"users", :action=>"show"}
#                invite_users POST   /users/invite(.:format)                                {:action=>"invite", :controller=>"users"}
#          autocomplete_users GET    /users/autocomplete(.:format)                          {:action=>"autocomplete", :controller=>"users"}
#                status_users GET    /users/status(.:format)                                {:action=>"status", :controller=>"users"}
#            specialties_user POST   /users/:id/specialties(.:format)                       {:action=>"specialties", :controller=>"users"}
#                 user_skills GET    /users/:user_id/skills(.:format)                       {:action=>"index", :controller=>"skills"}
#                             POST   /users/:user_id/skills(.:format)                       {:action=>"create", :controller=>"skills"}
#              new_user_skill GET    /users/:user_id/skills/new(.:format)                   {:action=>"new", :controller=>"skills"}
#             edit_user_skill GET    /users/:user_id/skills/:id/edit(.:format)              {:action=>"edit", :controller=>"skills"}
#                  user_skill GET    /users/:user_id/skills/:id(.:format)                   {:action=>"show", :controller=>"skills"}
#                             PUT    /users/:user_id/skills/:id(.:format)                   {:action=>"update", :controller=>"skills"}
#                             DELETE /users/:user_id/skills/:id(.:format)                   {:action=>"destroy", :controller=>"skills"}
#             user_highlights GET    /users/:user_id/highlights(.:format)                   {:action=>"index", :controller=>"highlights"}
#                             POST   /users/:user_id/highlights(.:format)                   {:action=>"create", :controller=>"highlights"}
#          new_user_highlight GET    /users/:user_id/highlights/new(.:format)               {:action=>"new", :controller=>"highlights"}
#         edit_user_highlight GET    /users/:user_id/highlights/:id/edit(.:format)          {:action=>"edit", :controller=>"highlights"}
#              user_highlight GET    /users/:user_id/highlights/:id(.:format)               {:action=>"show", :controller=>"highlights"}
#                             PUT    /users/:user_id/highlights/:id(.:format)               {:action=>"update", :controller=>"highlights"}
#                             DELETE /users/:user_id/highlights/:id(.:format)               {:action=>"destroy", :controller=>"highlights"}
#           user_endorsements GET    /users/:user_id/endorsements(.:format)                 {:action=>"index", :controller=>"endorsements"}
#                             POST   /users/:user_id/endorsements(.:format)                 {:action=>"create", :controller=>"endorsements"}
#        new_user_endorsement GET    /users/:user_id/endorsements/new(.:format)             {:action=>"new", :controller=>"endorsements"}
#       edit_user_endorsement GET    /users/:user_id/endorsements/:id/edit(.:format)        {:action=>"edit", :controller=>"endorsements"}
#            user_endorsement GET    /users/:user_id/endorsements/:id(.:format)             {:action=>"show", :controller=>"endorsements"}
#                             PUT    /users/:user_id/endorsements/:id(.:format)             {:action=>"update", :controller=>"endorsements"}
#                             DELETE /users/:user_id/endorsements/:id(.:format)             {:action=>"destroy", :controller=>"endorsements"}
#               user_pictures GET    /users/:user_id/pictures(.:format)                     {:action=>"index", :controller=>"pictures"}
#                             POST   /users/:user_id/pictures(.:format)                     {:action=>"create", :controller=>"pictures"}
#            new_user_picture GET    /users/:user_id/pictures/new(.:format)                 {:action=>"new", :controller=>"pictures"}
#           edit_user_picture GET    /users/:user_id/pictures/:id/edit(.:format)            {:action=>"edit", :controller=>"pictures"}
#                user_picture GET    /users/:user_id/pictures/:id(.:format)                 {:action=>"show", :controller=>"pictures"}
#                             PUT    /users/:user_id/pictures/:id(.:format)                 {:action=>"update", :controller=>"pictures"}
#                             DELETE /users/:user_id/pictures/:id(.:format)                 {:action=>"destroy", :controller=>"pictures"}
#                user_follows GET    /users/:user_id/follows(.:format)                      {:action=>"index", :controller=>"follows"}
#                             POST   /users/:user_id/follows(.:format)                      {:action=>"create", :controller=>"follows"}
#             new_user_follow GET    /users/:user_id/follows/new(.:format)                  {:action=>"new", :controller=>"follows"}
#            edit_user_follow GET    /users/:user_id/follows/:id/edit(.:format)             {:action=>"edit", :controller=>"follows"}
#                 user_follow GET    /users/:user_id/follows/:id(.:format)                  {:action=>"show", :controller=>"follows"}
#                             PUT    /users/:user_id/follows/:id(.:format)                  {:action=>"update", :controller=>"follows"}
#                             DELETE /users/:user_id/follows/:id(.:format)                  {:action=>"destroy", :controller=>"follows"}
#                       users GET    /users(.:format)                                       {:action=>"index", :controller=>"users"}
#                             POST   /users(.:format)                                       {:action=>"create", :controller=>"users"}
#                    new_user GET    /users/new(.:format)                                   {:action=>"new", :controller=>"users"}
#                   edit_user GET    /users/:id/edit(.:format)                              {:action=>"edit", :controller=>"users"}
#                        user GET    /users/:id(.:format)                                   {:action=>"show", :controller=>"users"}
#                             PUT    /users/:id(.:format)                                   {:action=>"update", :controller=>"users"}
#                             DELETE /users/:id(.:format)                                   {:action=>"destroy", :controller=>"users"}
#              clear_provider        /clear/:id/:provider(.:format)                         {:controller=>"users", :action=>"clear_provider"}
#                      visual        /visual(.:format)                                      {:controller=>"users", :action=>"beta"}
#                     refresh        /refresh/:username(.:format)                           {:controller=>"users", :action=>"refresh"}
#       random_accomplishment        /nextaccomplishment(.:format)                          {:controller=>"highlights", :action=>"random"}
#                   add_skill POST   /add-skill(.:format)                                   {:controller=>"skills", :action=>"create"}
#                  admin_root        /admin(.:format)                                       {:controller=>"admin", :action=>"index"}
#           admin_failed_jobs        /admin/failed_jobs(.:format)                           {:controller=>"admin", :action=>"failed_jobs"}
#           admin_cache_stats        /admin/cache_stats(.:format)                           {:controller=>"admin", :action=>"cache_stats"}
#                 admin_teams        /admin/teams(.:format)                                 {:controller=>"admin", :action=>"teams"}
#        admin_sections_teams        /admin/teams/sections/:num_sections(.:format)          {:controller=>"admin", :action=>"sections_teams"}
#         admin_section_teams        /admin/teams/section/:section(.:format)                {:controller=>"admin", :action=>"section_teams"}
#                                    /admin/resque
#                        blog        /blog(.:format)                                        {:controller=>"blog_posts", :action=>"index"}
#                   blog_post        /blog/:id(.:format)                                    {:controller=>"blog_posts", :action=>"show"}
#                        atom        /articles.atom(.:format)                               {:format=>:atom, :controller=>"blog_posts", :action=>"index"}
#                      signup        /                                                      {:controller=>"protips", :action=>"index"}
#                      signin        /signin(.:format)                                      {:controller=>"sessions", :action=>"signin"}
#                     signout        /signout(.:format)                                     {:controller=>"sessions", :action=>"destroy"}
#                    sign_out        /goodbye(.:format)                                     {:controller=>"sessions", :action=>"destroy"}
#                   dashboard        /dashboard(.:format)                                   {:controller=>"events", :action=>"index"}
#                 random_wall        /roll-the-dice(.:format)                               {:controller=>"users", :action=>"randomize"}
#                    trending        /trending(.:format)                                    {:controller=>"links", :action=>"index"}
#                       badge        /:username(.:format)                                   {:controller=>"users", :action=>"show"}
#            user_achievement        /:username/achievements/:id(.:format)                  {:controller=>"achievements", :action=>"show"}
#                                    /:username/endorsements.json(.:format)                 {:controller=>"endorsements", :action=>"show"}
#                   followers        /:username/followers(.:format)                         {:controller=>"follows", :action=>"index"}
#                   following        /:username/following(.:format)                         {:controller=>"follows", :action=>"index"}
#          user_activity_feed        /:username/events(.:format)                            {:controller=>"events", :action=>"index"}
#                                    /:username/events/more(.:format)                       {:controller=>"events", :action=>"more"}
#                                    /javascripts/*filename.js(.:format)                    {:controller=>"legacy", :action=>"show"}
#                                    /stylesheets/*filename.css(.:format)                   {:controller=>"legacy", :action=>"show"}
#                                    /images/*filename.png(.:format)                        {:controller=>"legacy", :action=>"show"}
#                                    /images/*filename.jpg(.:format)                        {:controller=>"legacy", :action=>"show"}
#                                    /:controller(/:action(/:id(.:format)))
#       letter_opener_letters        /letter_opener(.:format)                               {:controller=>"letter_opener/letters", :action=>"index"}
#        letter_opener_letter        /letter_opener/:id/:style.html(.:format)               {:controller=>"letter_opener/letters", :action=>"show"}
#

require 'resque/server'

Badgiy::Application.routes.draw do

  get "protips/update"
  put "protips/update"

  get "protip/update"
  put "protip/update"

  root :to => "protips#index"
  match 'welcome' => 'home#index', :as => :welcome

  mount ServeFonts.new, :at => "/fonts"
  match "/p/dpvbbg" => redirect("https://coderwall.com/p/devsal")
  match "/gh" => redirect("/?utm_campaign=github_orgs_badges&utm_source=github")

  topic_regex = /[A-Za-z0-9#\$\+\-_\.(%23)(%24)(%2B)]+/

  match "/comments" => "comments#index", :as => :latest_comments
  match "/jobs(/:location(/:skill))" => "opportunities#index", :as => :jobs
  match "/jobs-map" => "opportunities#map", :as => :jobs_map

  mount Split::Dashboard, :at => 'split'

  resources :protips, :path => "/p", :constraints => {:id => /[\dA-Z\-_]{6}/i} do
    collection { get 'random' }
    collection { get 'search' => "protips#search", :as => :search }
    collection { post 'search' => "protips#search" }
    collection { get 'me' => "protips#me", :as => :my }
    collection { get 'admin' => "protips#admin", :as => :reviewable }
    collection { get 'team/:team_slug' => "protips#team", :as => :team }
    collection { get 'd/:date(/:start)' => "protips#date", :as => :date }
    collection { get 't/trending' => "protips#trending", :as => :trending_topics }
    collection { get 't/by_tags' => "protips#by_tags", :as => :by_tags }
    collection { get 'u/:username' => "protips#user", :as => :user }
    collection { get 't/(/*tags)' => "networks#tag", :as => :tagged }
    #collection { get 't/(/*tags)' => "protips#topic",                    :as => :tagged}
    collection { put 't/(/*tags)/subscribe' => "protips#subscribe", :as => :subscribe }
    collection { put 't/(/*tags)/unsubscribe' => "protips#unsubscribe", :as => :unsubscribe }
    collection { get 'fresh' }
    collection { get 'trending' }
    collection { get 'popular' }
    collection { get 'liked' }
    collection { post 'preview' }

    member { post 'upvote' }
    member { post 'report_inappropriate' }
    member { post 'tag' }
    member { post 'flag' }
    member { post 'feature' }
    member { post 'queue/:queue' => 'protips#queue', :as => :queue }
    member { post 'delete_tag/:topic' => 'protips#delete_tag', :as => :delete_tag, :topic => topic_regex }
    resources :comments, :constraints => {:id => /\d+/} do
      member { post 'like' }
    end
  end

  resources :networks, :path => "/n", :constraints => {:slug => /[\dA-Z\-]/i} do
    collection { get 'featured' => "networks#featured", :as => :featured }
    collection { get '/u/:username' => "networks#user", :as => :user }
    member { get '/t/(/*tags)' => "networks#tag", :as => :tagged }
    member { get '/members' => "networks#members", :as => :members }
    member { get '/mayor' => "networks#mayor", :as => :mayor }
    member { get '/expert' => "networks#expert", :as => :expert }
    member { post '/join' => "networks#join", :as => :join }
    member { post '/leave' => "networks#leave", :as => :leave }
    member { post '/update-tags' => "networks#update_tags", :as => :update_tags }
    member { get '/current-mayor' => "networks#current_mayor", :as => :current_mayor }
  end

  resources :processing_queues, :path => "/q" do
    member { post '/dequeue/:item' => "processing_queues#dequeue", :as => :dequeue }
  end

  match 'trending' => 'protips#index', :as => :protips

  if Rails.env.development?
    match "/letter_opener" => 'letter_opener/letters#index', :as => :letter_opener_letters
    match "/letter_opener/:id/:style.html" => 'letter_opener/letters#show', :as => :letter_opener_letter
    mount Campaigns::Preview => 'campaigns'
    mount Notifier::Preview => 'mail'
    mount WeeklyDigest::Preview => 'digest'
    mount Subscription::Preview => 'subscription'
  end

  match 'faq' => 'pages#show', :page => :faq, :as => :faq
  match 'tos' => 'pages#show', :page => :tos, :as => :tos
  match 'privacy_policy' => 'pages#show', :page => :privacy_policy, :as => :privacy_policy
  match 'contact_us' => 'pages#show', :page => :contact_us, :as => :contact_us
  match 'api' => 'pages#show', :page => :api, :as => :api
  match 'achievements' => 'pages#show', :page => :achievements, :as => :achievements if Rails.env.development?
  match '/pages/:page' => 'pages#show'

  match 'award' => 'achievements#award', :as => :award_badge

  match '/auth/:provider/callback' => 'sessions#create', :as => :authenticate
  match '/auth/failure' => 'sessions#failure', :as => :authentication_failure
  match '/settings' => 'users#edit', :as => :settings
  match '/redeem/:code' => 'redemptions#show'
  match '/unsubscribe' => 'emails#unsubscribe'
  match '/delivered' => 'emails#delivered'
  match "/delete_account" => 'users#delete_account', :as => :delete_account
  match "/delete_account_confirmed" => 'users#delete_account_confirmed', :as => :delete_account_confirmed, :via => :post


  resources :authentications, :usernames
  resources :invitations
  match '/i/:id/:r' => 'invitations#show', :as => :invitation

  resources :sessions do
    collection { get('force') }
  end

  match 'webhooks/stripe' => "accounts#webhook"
  match '/alerts' => "alerts#create", :via => :post
  match '/alerts' => "alerts#index", :via => :get

  #match '/payment' => "accounts#new", :as => :payment

  match '/users/:username/follow' => 'follows#create', :as => :follow_user, :type => :user, :via => :post

  match '/team/:slug' => 'teams#show', :as => :teamname
  match '/team/:slug/edit' => 'teams#edit', :as => :teamname_edit
  match '/team/:slug/(:job_id)' => 'teams#show', :as => :job

  resources :teams do
    collection { post 'inquiry' }
    member { get 'accept' }
    member { post 'record-exit' => "teams#record_exit", :as => :record_exit }
    member { get 'visitors' }
    member { post 'follow' => 'follows#create', :type => :team }
    member { post 'join' }
    member { post 'join/:user_id/approve' => 'teams#approve_join', :as => :approve_join }
    member { post 'join/:user_id/deny' => 'teams#deny_join', :as => :deny_join }
    collection { get 'followed' }
    collection { get 'search' }
    resources :team_members
    resources :team_locations, :as => :locations
    resources :opportunities do
      member { post 'apply' }
      member { get 'activate' }
      member { get 'deactivate' }
      member { post 'visit' }
    end
    resource :account do
      collection { post 'send_invoice' => 'accounts#send_invoice' }
    end
  end


  match '/leaderboard' => 'teams#leaderboard', :as => :leaderboard
  match '/employers' => 'teams#upgrade', :as => :employers

  ['github', 'twitter', 'forrst', 'dribbble', 'linkedin', 'codeplex', 'bitbucket', 'stackoverflow'].each do |provider|
    match "/#{provider}/unlink" => 'users#unlink_provider', :provider => provider, :via => :post, :as => "unlink_#{provider}".to_sym
    match "/#{provider}/:username" => 'users#show', :provider => provider
  end

  resources :users do
    collection {
      post 'invite'
      get 'autocomplete'
      get 'status'
    }
    member {
      post 'specialties'
    }
    resources :skills
    resources :highlights
    resources :endorsements
    resources :pictures
    resources :follows
  end

  match 'clear/:id/:provider' => 'users#clear_provider', :as => :clear_provider
  match '/visual' => 'users#beta'
  match '/refresh/:username' => 'users#refresh', :as => :refresh
  match '/nextaccomplishment' => 'highlights#random', :as => :random_accomplishment
  match '/add-skill' => 'skills#create', :as => :add_skill, :via => :post

  require_admin = lambda do |params, req|
    User.where(:id => req.session[:current_user]).first.try(:admin?)
  end

  scope :admin, :as => :admin, :path => '/admin', :constraints => require_admin do
    match "/" => "admin#index", :as => :root
    match "/failed_jobs" => "admin#failed_jobs"
    match "/cache_stats" => "admin#cache_stats"
    match "/teams" => "admin#teams", :as => :teams
    match "/teams/sections/:num_sections" => "admin#sections_teams", :as => :sections_teams
    match "/teams/section/:section" => "admin#section_teams", :as => :section_teams
    mount Resque::Server.new, :at => "/resque"
  end

  match '/blog' => "blog_posts#index", :as => :blog
  match '/blog/:id' => "blog_posts#show", :as => :blog_post
  match '/articles.atom' => "blog_posts#index", :as => :atom, :format => :atom

  match '/' => 'protips#index', :as => :signup
  match '/signin' => 'sessions#signin', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/goodbye' => 'sessions#destroy', :as => :sign_out

  match '/dashboard' => 'events#index', :as => :dashboard
  match '/roll-the-dice' => 'users#randomize', :as => :random_wall
  match '/trending' => 'links#index', :as => :trending
  match '/:username' => 'users#show', :as => :badge
  match '/:username/achievements/:id' => 'achievements#show', :as => :user_achievement
  match '/:username/endorsements.json' => 'endorsements#show'
  match '/:username/followers' => 'follows#index', :as => :followers, :type => :followers
  match '/:username/following' => 'follows#index', :as => :following, :type => :following
  match '/:username/events' => 'events#index', :as => :user_activity_feed
  match '/:username/events/more' => 'events#more'

  match '/javascripts/*filename.js' => 'legacy#show', :extension => 'js'
  match '/stylesheets/*filename.css' => 'legacy#show', :extension => 'css'
  match '/images/*filename.png' => 'legacy#show', :extension => 'png'
  match '/images/*filename.jpg' => 'legacy#show', :extension => 'jpg'

  match ':controller(/:action(/:id(.:format)))' if Rails.env.test? || Rails.env.development?

  # match "/admin/#{ENV['PRIVATE_ADMIN_PATH']}" => 'home#report' unless ENV['PRIVATE_ADMIN_PATH'].blank?
  #
  namespace :callbacks do
      post '/hawt/feature'   => 'hawt#feature'
      post '/hawt/unfeature' => 'hawt#unfeature'
  end
end
