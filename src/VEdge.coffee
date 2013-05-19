class VEdge
  constructor: (@start, @left, @right) ->
    @end = null
    @f = (@right.x - @left.x)/(@left.y - @right.y)
    @g = @start.y - @f * @start.x
    @direction = new Point @right.y - @left.y, -(@right.x - @left.x)
    @B = new Point @start.x + @direction.x, @start.y + @direction.y

    @intersected = false
    @isCounted = false

    @neighbour = null