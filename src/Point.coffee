class Point
  constructor: (@x, @y) ->

  distance: (a, b)->
    Math.sqrt (b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.x - a.x)
    