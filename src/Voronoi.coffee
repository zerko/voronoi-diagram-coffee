class Voronoi
  constructor: ->
    @sites = null
    @edges = null
    @cells = null
    @queue = new VQueue

    @width = 0
    @height = 0
    @root = null
    @ly = 0
    @lasty = 0
    @fp = null

  compute: (@sites, @width, @height)->
    return [] if @sites.length < 2
    @root = null
    @edges = []
    @cells = []
    do @queue.clear

    for site in @sites
      ev = new VEvent(site, true)
      cell = new VPolygon
      site.cell = cell
      @queue.enqueue ev
      @cells.push cell

    while !@queue.isEmpty()
      e = @queue.dequeue()
      @ly = e.point.y
      if e.pe
        @insertParabola e.point
      else
        @removeParabola e
    @finishEdge @root

    for edge in @edges
      if edge.neighbour
        edge.start = edge.neighbour.end

  insertParabola: (p)->
    if !@root
      @root = new VParabola p
      @fp = p
      return

    if @root.isLeaf && (@root.site.y - p.y) < 0.01 # first two sites on same height
      @root.isLeaf = false
      @root.setLeft new VParabola @fp
      @root.setRight new VParabola p
      s = new Point (p.x + @fp.x)/2, @height
      if p.x > @fp.x
        @root.edge = new VEdge s, @fp, p
      else
        @root.edge = new VEdge s, p, @fp
      @edges.push @root.edge
      return
    par = @getParabolaByX p.x
    if par.cEvent
      @queue.remove par.cEvent
      par.cEvent = null

    start = new Point p.x, @getY par.site, p.x
    el = new VEdge start, par.site, p
    er = new VEdge start, p, par.site

    el.neighbour = er
    @edges.push el

    par.edge = er
    par.isLeaf = false

    p0 = new VParabola par.site
    p1 = new VParabola p
    p2 = new VParabola par.site

    par.setRight p2
    par.setLeft new VParabola
    par.left.edge = el

    par.left.setLeft p0
    par.left.setRight p1

    @checkCircle p0
    @checkCircle p2

  removeParabola: (e)->
    p1 = e.arch

    xl = @getLeftParent p1
    xr = @getRightParent p1

    p0 = @getLeftChild xl
    p2 = @getRightChild xr

    if p0.cEvent
      @queue.remove p0.cEvent
      p0.cEvent = null
    if p2.cEvent
      @queue.remove p2.cEvent
      p2.cEvent = null
    p = new Point e.point.x, @getY(p1.site, e.point.x)

    if p0.site.cell.last == p1.site.cell.first
       p1.site.cell.addLeft p
    else
      p1.site.cell.addRight p

    p0.site.cell.addRight p
    p2.site.cell.addLeft p

    @lasty = e.point.y

    xl.edge.end = p
    xr.edge.end = p

    par = p1
    while par != @root
      par = par.parent;
      higher = xl if par == xl
      higher = xr if par == xr
    higher.edge = new VEdge p, p0.site, p2.site

    @edges.push higher.edge

    gparent = p1.parent.parent
    if p1.parent.left == p1
      if gparent.left  == p1.parent
        gparent.setLeft p1.parent.right
      else
        p1.parent.parent.setRight p1.parent.right
    else
      if gparent.left  == p1.parent
        gparent.setLeft p1.parent.left;
      else
        gparent.setRight p1.parent.left;

    @checkCircle(p0);
    @checkCircle(p2)

  finishEdge: (n)->
    if n.edge.direction.x > 0.0
      mx = Math.max @width, n.edge.start.x + 10
    else
      mx = Math.min 0.0, n.edge.start.x - 10

    n.edge.end = new Point mx, n.edge.f*mx + n.edge.g
    @finishEdge n.left if !n.left.isLeaf
    @finishEdge n.right if !n.right.isLeaf

  getXOfEdge: (par, y)->
    left = @getLeftChild par
    right = @getRightChild par

    p = left.site
    r = right.site
    dp = 2*(p.y - y)
    a1 = 1/dp
    b1 = -2*p.x/dp
    c1 = y+dp*0.25 + p.x*p.x/dp

    dp = 2*(r.y - y)
    a2 = 1/dp
    b2 = -2*r.x/dp
    c2 = y+dp*0.25 + r.x*r.x/dp

    a = a1 - a2
    b = b1 - b2
    c = c1 - c2

    disc = b*b - 4 * a * c
    x1 = (-b + Math.sqrt(disc)) / (2*a)
    x2 = (-b - Math.sqrt(disc)) / (2*a)

    if p.y < r.y
      ry = Math.max x1, x2
    else
      ry = Math.min x1, x2
    return ry

  getParabolaByX: (xx)->
    par = @root
    x = 0

    while !par.isLeaf
      x = @getXOfEdge par, @ly
      if x > xx
        par = par.left
      else
        par = par.right
    return par

  getY: (p, x)->
    dp = 2*(p.y - @ly)
    b1 = -2*p.x/dp
    c1 = @ly+dp/4 + p.x*p.x/dp

    x*x/dp + b1*x + c1

  checkCircle: (b)->
    lp = @getLeftParent b
    rp = @getRightParent b

    a = @getLeftChild lp
    c = @getRightChild rp

    if !a || !c || (a.site == c.site)
      return

    s = @getEdgeIntersection lp.edge, rp.edge
    if !s
      return

    # FIXME
    d = Point.prototype.distance a.site, s

    if (s.y - d) >= @ly
       return;
    e = new VEvent new Point(s.x, s.y - d), false

    b.cEvent = e
    e.arch = b
    @queue.enqueue e

  getEdgeIntersection: (a, b)->
    I = @getLineIntersection a.start, a.B, b.start, b.B

    # wrong direction of edge
    wd = (I.x - a.start.x)*a.direction.x<0 || (I.y - a.start.y)*a.direction.y<0 || (I.x - b.start.x)*b.direction.x<0 || (I.y - b.start.y)*b.direction.y<0
    if wd
      return null
    return I

  getLeftParent: (n)->
    par = n.parent
    pLast = n
    while par.left == pLast
      if !par.parent
        return null
      pLast = par
      par = par.parent
    return par

  getRightParent: (n)->
    par = n.parent
    pLast = n
    while par.right == pLast
      if !par.parent
        return null
      pLast = par
      par = par.parent
    return par

  getLeftChild: (n)->
    if !n
      return null
    par = n.left
    while !par.isLeaf
      par = par.right
    return par

  getRightChild: (n)->
    if !n
      return null
    par = n.right
    while !par.isLeaf
      par = par.left
    return par

  getLineIntersection: (a1, a2, b1, b2)->
    dax = a1.x-a2.x
    dbx = b1.x-b2.x
    day = a1.y-a2.y
    dby = b1.y-b2.y

    den = dax*dby - day*dbx
    if den == 0
       return null # parallel

    A = a1.x * a2.y - a1.y * a2.x
    B = b1.x * b2.y - b1.y * b2.x

    I = new Point 0,0
    I.x = ( A*dbx - dax*B ) / den
    I.y = ( A*dby - day*B ) / den

    return I

