class window.Moveable
  id: null
  element: null
  innerElement: null
  handler: null

  constructor: (params) ->

  x: -> parseInt(@element.css('x'))
  y: -> parseInt(@element.css('y'))
  w: -> parseInt(@innerElement.css('width'))
  h: -> parseInt(@innerElement.css('height'))

  setXY: (x, y, moveFunc = $.fn.css, duration) ->
    @element.moveFunc {
      x: x,
      y: y
    }, duration

  setWH: (w, h, moveFunc = $.fn.css, duration) ->
    @innerElement.moveFunc {
      width: w,
      height: h
    }, duration
