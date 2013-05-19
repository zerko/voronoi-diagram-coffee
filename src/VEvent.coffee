class VEvent
  constructor: (@point, @pe)->
    @y = @point.y
    @key = Math.random()*100000000

    @arch = null
    @value = 0

  compare: (other)->
    if @y - other.y
      1
    else
      -1
