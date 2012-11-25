class window.MiniSheet
  id: null
  element: null

  constructor: (id) ->
    @id = id
    @element = $($('<div class = "minimapElement"></div>').appendTo('#minimapElements'))
    @element.attr('id', 'map_sheet' + id)
    @element.on 'mousedown', @onMouseDown
    
  becomeActive: () =>
    @element.css 'background-color', 'crimson'

  resignActive: () =>
    @element.css 'background-color', 'black'

  becomeSelected: () =>
    @element.css 'background-color', '#96A6D6'

  remove: () ->
    @element.remove()
    #delete miniSheets[@id]

  getXY: () ->
    x: parseInt(@element.css('x'))
    y: parseInt(@element.css('y'))

  setXY: (x, y, moveFunc = $.fn.css, duration) ->
    @element.moveFunc {
      x: x,
      y: y
    }, duration

  getWH: () ->
    w: parseInt(@element.css('width'))
    h: parseInt(@element.css('height'))

  setWH: (w, h, moveFunc = $.fn.css, duration) ->
    @element.moveFunc {
      width: w,
      height: h
    }, duration

  onMouseDown: (e) =>
    @becomeSelected()
    sheet = sheets[@id]
    wall.toCenter(sheet, @resignActive)
    return false
