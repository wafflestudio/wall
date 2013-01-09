class window.Movable
  id: null
  element: null
  innerElement: null
  handler: null

  constructor: (params) ->
  
  x: (x) ->
    return parseInt(@element.css('x')) unless x?
    @element.css {x: x}

  y: (y) ->
    return parseInt(@element.css('y')) unless y?
    @element.css {y: y}

  w: (w) ->
    return parseInt(@element.css('width')) unless w?
    @element.css {width: w}

  h: (h) ->
    return parseInt(@element.css('height')) unless h?
    @element.css {height: h}
  
  iw: (w) ->
    return parseInt(@innerElement.css('width')) unless w?
    @innerElement.css {width: w}

  ih: (h) ->
    return parseInt(@innerElement.css('height')) unless h?
    @innerElement.css {height: h}

  tXY: (x, y, callback) ->
    @element.transition {
      x: x
      y: y
    }, callback

  tiWH: (w, h, callback) ->
    @innerElement.transition {
      width: w
      height: h
    }, callback
 
  redraw: () ->
    @element.redraw2d()
