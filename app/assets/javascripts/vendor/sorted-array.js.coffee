Ember.SortedArrayController = Ember.ArrayController.extend(
  sortOrder: "normal"
  sortFunction: null
  inputCollectionName: "content"
  outputCollectionName: "content"
  maxCollectionSize: -1

  init: ->
    @set(@inputCollectionName, [])
    @addObserver(@inputCollectionName + '.@each', ->
      @elementAdded())
    @addObserver(@outputCollectionName + '.@each', ->
      @trimArray())

  elementAdded: (->
    context = @
    content = @get(@inputCollectionName)

    if @sortOrder == "normal"
      if @sortFunction? then content.sort((a, b)->
        context.sortFunction(a, b))
      else
      content.sort()
    else if @sortOrder == "reverse"
      if @sortFunction? then content.sort((a, b)->
        context.sortFunction(b, a))
      else
      content.reverse()
    else if @sortOrder == "random"
      content.sort((a, b)->
        0.5 - Math.random("deadbeef"))

    @set(@outputCollectionName, content)
  )

  trimArray: (->
    content = @get(@outputCollectionName)
    @set(@outputCollectionName,
      content.slice(0, @maxCollectionSize - 1))if (@maxCollectionSize > 0) and (content.length > @maxCollectionSize)
  )
)

#window.myArray = Ember.SortedArrayController.create()
#myArray.content.pushObjects(["Jack", "Cassandra", "Raj"])

#window.myArray2 = Ember.SortedArrayController.create({sortOrder: "reverse"})
#myArray2.content.pushObjects(["Jack", "Cassandra", "Raj"])
#
#window.myArray3 = Ember.SortedArrayController.create({sortOrder: "random"})
#myArray3.content.pushObjects(["Jack", "Cassandra", "Raj"])
