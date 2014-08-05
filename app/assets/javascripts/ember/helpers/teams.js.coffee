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