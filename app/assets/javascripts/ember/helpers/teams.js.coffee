Handlebars.registerHelper "compare", (lvalue, rvalue, options) ->
  throw new Error("Handlerbars Helper 'compare' needs 2 parameters")  if arguments.length < 3
  operator = options.hash.operator or "=="
  operators =
    "==": (l, r) ->
      l is r

    "===": (l, r) ->
      l is r

    "!=": (l, r) ->
      l isnt r

    "<": (l, r) ->
      l < r

    ">": (l, r) ->
      l > r

    "<=": (l, r) ->
      l <= r

    ">=": (l, r) ->
      l >= r

    typeof: (l, r) ->
      typeof l is r

  throw new Error("Handlerbars Helper 'compare' doesn't support the operator " + operator)  unless operators[operator]
  result = operators[operator](lvalue, rvalue)
  if result
    options.fn this
  else
    options.inverse this

Handlebars.registerHelper "signed_in", ->
  UsersController.signedInUser?

#Handlebars.registerHelper "remaining_team_member_count", (team_members) ->
#  team_members - 3
#
#Handlebars.registerHelper "following", (team_name, options) ->
#  if defined? Coderwall.teamsController.followedTeamsList[team_name]
#    options.fn @
#  else if defined? elsefn
#    options.else.fn @
#
#Handlebars.registerHelper "plusone", (team_members) ->
#  team_members+1
#
