class VParabola
  constructor: (@site)->
    @cEvent = null
    @parent = null
    @left = null
    @right = null

    @isLeaf = @site?

  setLeft: (p)->
    @left = p
    p.parent = @

  setRight: (p)->
    @right = p
    p.parent = @
