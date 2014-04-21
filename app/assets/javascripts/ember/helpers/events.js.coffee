Handlebars.registerHelper "tagged_protips_path", ->
  "/p/t/" + encodeURI(@)

Handlebars.registerHelper "write_tagged_protips_path", ->
  '/p/new?topics=' + encodeURI(@)

Handlebars.registerHelper "image_path", ->
  '/assets/' + @

Handlebars.registerHelper "any_skills", ->
  @.length > 0

Handlebars.registerHelper "followed_text", ->
  if @.toString() == 'followed_team' then "is now following your team." else "is now following you."

Handlebars.registerHelper "comment_action", ->
  if @.event_type == 'new_comment' then "Your protip" else if @.likes > 0 then "Your comment on protip" else ""

Handlebars.registerHelper "comment_or_like_message", ->
  if @.event_type == 'new_comment' then "now has " + @.comments + " comments" else if @.likes > 0 then "now has " + @.likes + " likes" else ""

Handlebars.registerHelper "if_repliable", (block)->
  if @.event_type == 'new_comment' or @.event_type == 'comment_reply' then block(@)

Handlebars.registerHelper "reply_url", ->
  @.url + encodeURI("?reply_to=@" + @.user.username + " #add-comment")
