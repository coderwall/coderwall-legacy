Coderwall.networksController = Ember.SortedArrayController.create(
  inputCollectionName: "content"
  outputCollectionName: "content"
  sortOrder: "normal"
  sortField: "name"

  sortFunction: (networkA, networkB) ->
    if @sortField is "name"
      @sortFunctionAlphabetical(networkA, networkB)
    else if @sortField is "upvotes"
      @sortFunctionUpvotes(networkA, networkB)
    else if @sortField is "created_at"
      @sortFunctionCreatedAt(networkA, networkB)

  sortFunctionAlphabetical: (networkA, networkB)->
    if networkA.name < networkB.name
      -1
    else if networkA.name > networkB.name
      1
    else
      0

  sortFunctionUpvotes: (networkA, networkB)->
    networkA.upvotes - networkB.upvotes

  sortFunctionCreatedAt: (networkA, networkB)->
    networkA.created_at - networkB.created_at


)