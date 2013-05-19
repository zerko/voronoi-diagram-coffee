# counter clock wise
# (-1,1), (1,1), (1,-1), (-1,-1)
class VPolygon
  constructor: ->
    @size = 0
    @verticies = []
    @first = null
    @last = null

  addRight: (p)->
    @verticies.push p
    @size++
    @last = p
    @first = p if @size == 1

  addLeft: (p)->
    @verticies.unshift p
    @size++
    @first = p
    @last = p if @size == 1
