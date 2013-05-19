class VQueue
  constructor: ->
    @q = []

  enqueue: (p)->
    @q.push p

  dequeue: ->
    @q.sort (a,b)-> a.y - b.y
    @q.pop()

  remove: (e)->
    index = -1
    for qe, i in @q
      if qe == e
        index = i
        break
    @q.splice index, 1

  isEmpty: ->
    @q.length == 0

  clear: ->
    @q = []
