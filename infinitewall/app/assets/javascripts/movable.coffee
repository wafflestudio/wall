class window.Movable
  id: null
  element: null
  innerElement: null
  handler: null

  constructor: (params) ->
  
  # 규칙 =>
  # 아무것도 안붙으면 @element의 값들의 애니메이션 없는 getter + setter
  # i가 붙으면 @innerElement의 값들에 대한 애니메이션 없는 getter + setter
  # t가 붙으면 transition animation이 됨
  # c는 center value => 사각형의 정 중앙을 뜻함

  x: (x) ->
    return parseInt(@element.css('x')) unless x?
    @element.css {x: x}

  y: (y) ->
    return parseInt(@element.css('y')) unless y?
    @element.css {y: y}

  cx: (centerX) ->
    return @x() + @w() / 2 unless centerX?
    @element.css {x: centerX - @w() / 2}

  cy: (centerY) ->
    return @y() + @h() / 2 unless centerY?
    @element.css {y: centerY - @h() / 2}

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

  txywh: (x, y, w, h, callback) ->
    @element.transition {
      x: x
      y: y
      width: w
      height: h
    }, callback

  tiWH: (w, h, callback) ->
    @innerElement.transition {
      width: w
      height: h
    }, callback

  xy: (x, y) ->
    @element.css {
      x: x
      y: y
    }

  wh: (w, h) ->
    @element.css {
      width: w
      height: h
    }

  iwh: (w, h) ->
    @innerElement.css {
      width: w
      height: h
    }

  xywh: (x, y, w, h) ->
    @element.css {
      x: x
      y: y
      width: w
      height: h
    }

  xyiwh: (x, y, w, h) ->
    @element.css {
      x: x
      y: y
    }

    @innerElement.css {
      width: w
      height: h
    }
 
  redraw: ->
    @element.redraw2d()
