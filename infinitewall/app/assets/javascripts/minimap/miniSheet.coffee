class window.MiniSheet extends Movable
  constructor: (params) ->
    @id = params.id
    @element = $($('<div class = "miniSheet"></div>').appendTo('#miniMoveLayer'))
    #@xywh(params.x, params.y, params.width, params.height)
    @element.attr('id', 'map_sheet' + @id)
    @element.on 'mousedown', @onMouseDown
    
  becomeActive: =>
    @element.css 'background-color', 'crimson'

  resignActive: =>
    @element.css 'background-color', 'black'

  becomeSelected: =>
    @element.css 'background-color', '#96A6D6'

  remove: ->
    @element.remove()

  onMouseDown: (e) =>
    @becomeSelected()
    sheet = sheets[@id]
    wall.toCenter(sheet, @resignActive)
    return false
