Coderwall.AllNetworksView = Ember.View.create(
  alphabet: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
             "V", "W", "X", "Y", "Z"]
  tagName: "div"
  sortOrder: 'a_z'
  networksBinding: "Coderwall.networksController.content"

  templateName: (->
    templateName = if @get('sortOrder')? then @get('sortOrder') else "a_z"
    "networks/all_networks/" + templateName
  ).property("sortOrder").cacheable()

  sortByAlpyhabet: ->
    Coderwall.networksController.set('sortField', 'name')
    @set('sortOrder', 'a_z')

  sortByUpvotes: ->
    Coderwall.networksController.set('sortField', 'upvotes')
    @set('sortOrder', 'upvotes')

  sortByNewProtips: ->
    Coderwall.networksController.set('sortField', 'created_at')
    @set('sortOrder', 'new')

  showMembers: ->

)

Coderwall.AllNetworksView.appendTo('#networks')
