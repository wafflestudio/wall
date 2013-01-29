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
    @element.css {x: Math.round(x)}

  y: (y) ->
    return parseInt(@element.css('y')) unless y?
    @element.css {y: Math.round(y)}

  left: (l) ->
    @x(l)

  right: (r) ->
    return @x() + @w() unless r?
    @x(r - @w())

  top: (t) ->
    @y(t)

  bottom: (b) ->
    return @y() + @h() unless b?
    @y(b - @h())

  cx: (centerX) ->
    return @x() + @w() / 2 unless centerX?
    @element.css {x: Math.round(centerX - @w() / 2)}

  cy: (centerY) ->
    return @y() + @h() / 2 unless centerY?
    @element.css {y: Math.round(centerY - @h() / 2)}

  w: (w) ->
    return parseInt(@element.css('width')) unless w?
    @element.css {width: Math.round(w)}

  h: (h) ->
    return parseInt(@element.css('height')) unless h?
    @element.css {height: Math.round(h)}
  
  iw: (w) ->
    return parseInt(@innerElement.css('width')) unless w?
    @innerElement.css {width: Math.round(w)}

  ih: (h) ->
    return parseInt(@innerElement.css('height')) unless h?
    @innerElement.css {height: Math.round(h)}

  tXY: (x, y, duration, callback) ->
    @element.transition {
      x: Math.round(x)
      y: Math.round(y)
    }, duration, callback

  txywh: (x, y, w, h, duration, callback) ->
    @element.transition {
      x: Math.round(x)
      y: Math.round(y)
      width: Math.round(w)
      height: Math.round(h)
    }, duration, callback

  tiWH: (w, h, callback) ->
    @innerElement.transition {
      width: Math.round(w)
      height: Math.round(h)
    }, callback

  xy: (x, y) ->
    @element.css {
      x: Math.round(x)
      y: Math.round(y)
    }

  wh: (w, h) ->
    @element.css {
      width: Math.round(w)
      height: Math.round(h)
    }

  iwh: (w, h) ->
    @innerElement.css {
      width: Math.round(w)
      height: Math.round(h)
    }

  xywh: (x, y, w, h) ->
    @element.css {
      x: Math.round(x)
      y: Math.round(y)
      width: Math.round(w)
      height: Math.round(h)
    }

  xyiwh: (x, y, w, h) ->
    @element.css {
      x: Math.round(x)
      y: Math.round(y)
    }

    @innerElement.css {
      width: Math.round(w)
      height: Math.round(h)
    }
