Function::define = (prop, desc) ->
  Object.defineProperty(this.prototype, prop, desc)

cellVal = 100

class window.Movable
  id: null
  element: null
  innerElement: null
  handler: null
  timer: 0

  #i 는 안에 들어있는 element에 대한것
  #c 는 중심의 좌표
  constructor: (isCell = false) ->
    if isCell

      Object.defineProperty @, 'x', {
        get: -> parseInt(@element.css('x'))
        set: (value) ->
          roundVal = Math.round(value)
          diff = roundVal % cellVal

          if diff > cellVal / 2
            @element.css {x: roundVal - diff + cellVal}
          else
            @element.css {x: roundVal - diff}
      }

      Object.defineProperty @, 'y', {
        get: -> parseInt(@element.css('y'))
        set: (value) ->
          roundVal = Math.round(value)
          diff = roundVal % cellVal

          if diff > cellVal / 2
            @element.css {y: roundVal - diff + cellVal}
          else
            @element.css {y: roundVal - diff}
      }

      Object.defineProperty @, 'iw', {
        get: -> parseInt(@innerElement.css('width'))
        set: (value) ->
          roundVal = Math.round(value)
          diff = roundVal % cellVal

          if diff > cellVal / 2
            @innerElement.css {width: roundVal - diff + cellVal}
          else
            @innerElement.css {width: roundVal - diff}
      }

      Object.defineProperty @, 'ih', {
        get: -> parseInt(@innerElement.css('height'))
        set: (value) ->
          roundVal = Math.round(value)
          diff = roundVal % cellVal

          if diff > cellVal / 2
            @innerElement.css {height: roundVal - diff + cellVal}
          else
            @innerElement.css {height: roundVal - diff}
      }

    else
      Object.defineProperty @, 'x', {
        get: -> parseInt(@element.css('x'))
        set: (value) -> @element.css {x: Math.round(value)}
      }

      Object.defineProperty @, 'y', {
        get: -> parseInt(@element.css('y'))
        set: (value) -> @element.css {y: Math.round(value)}
      }

      Object.defineProperty @, 'iw', {
        get: -> parseInt(@innerElement.css('width'))
        set: (value) -> @innerElement.css {width: Math.round(value)}
      }

      Object.defineProperty @, 'ih', {
        get: -> parseInt(@innerElement.css('height'))
        set: (value) -> @innerElement.css {height: Math.round(value)}
      }

  @define 'w', {
    get: -> parseInt(@element.css('width'))
    set: (value) -> @element.css {width: Math.round(value)}
  }

  @define 'h', {
    get: -> parseInt(@element.css('height'))
    set: (value) -> @element.css {height: Math.round(value)}
  }

  @define 'left', {
    get: -> @x
    set: (value) -> @x = value
  }

  @define 'right', {
    get: -> @x + @w
    set: (value) -> @x = value - @w
  }

  @define 'top', {
    get: -> @y
    set: (value) -> @y = value
  }

  @define 'bottom', {
    get: -> @y + @h
    set: (value) -> @y = value - @h
  }

  @define 'cx', {
    get: -> @x + @w / 2
    set: (value) -> @element.css {x: Math.round(value - @w / 2)}
  }

  @define 'cy', {
    get: -> @y + @h / 2
    set: (value) -> @element.css {y: Math.round(value - @h / 2)}
  }

  ## t가 붙으면 transition animation이 됨

  smoothmove: (endx, endy) ->
    clearTimeout(@timer)
    @timer = setInterval (=>
      if Math.abs(@x() - endx) < 2 and Math.abs(@y() - endy) < 2
        @x(endx)
        @y(endy)
        clearTimeout(@timer)

      interx = 0.9 * @x() + 0.1 * endx
      intery = 0.9 * @y() + 0.1 * endy
      @x(interx)
      @y(intery)), 5

  txy: (x, y, duration, callback) ->
    console.log "txy: ", x, y
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

  isTransitioning: ->
    Boolean(@element.queue().length)
