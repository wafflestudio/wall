class window.SheetHandler
  
  sheet: null
  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  startWidth: 0
  startHeight: 0
  hasMoved: false

  constructor: (params) ->
    @sheet = params
    @sheet.element.on 'mousedown', '.boxClose', @onButtonMouseDown
    @sheet.element.on 'mousedown', '.resizeHandle', @onResizeMouseDown
    @sheet.element.on 'mousedown', @onMouseDown
    @sheet.element.on 'setText', (e) =>
      @sheet.socketSetText()

  onMouseMove: (e) =>

    newX = (@startx + e.pageX - @deltax) / glob.zoomLevel
    newY = (@starty + e.pageY - @deltay) / glob.zoomLevel
    @sheet.setXY(newX, newY)
    @hasMoved = true
    minimap.refresh()
   
  onMouseUp: (e) =>
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp

    if @hasMoved
      @sheet.socketMove {
        x: (@startx + e.pageX - @deltax) / glob.zoomLevel,
        y: (@starty + e.pageY - @deltay) / glob.zoomLevel
      }
    else
      if glob.activeSheet
        glob.activeSheet.resignActive()
      
      @sheet.becomeActive()
      miniSheets[@sheet.id].becomeActive()
      
      #@sheet.element.find('.sheetTextField').focus()
      #@sheet.element.find('.sheetTextField').trigger('activate')
      
      wall.revealSheet()

  onMouseDown: (e) =>
    @hasMoved = false
    wall.bringToTop(@sheet)
    minimap.bringToTop(miniSheets[@sheet.id])
    
    @startx = @sheet.getXY().x * glob.zoomLevel
    @starty = @sheet.getXY().y * glob.zoomLevel

    @deltax = e.pageX
    @deltay = e.pageY

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    e.stopPropagation()

  onButtonMouseDown: (e) =>
    $(document).on 'mouseup', @onButtonMouseUp
  
  onButtonMouseUp: (e) =>
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    @sheet.socketRemove()
  
  onResizeMouseDown: (e) =>
    $(document).on 'mousemove', @onResizeMouseMove
    $(document).on 'mouseup', @onResizeMouseUp
    @startWidth = @sheet.getWH().w * glob.zoomLevel
    @startHeight = @sheet.getWH().h * glob.zoomLevel
    @deltax = e.pageX
    @deltay = e.pageY
    return false

  onResizeMouseMove: (e) =>

  onResizeMouseUp: (e) =>
    $(document).off 'mousemove', @onResizeMouseMove
    $(document).off 'mouseup', @onResizeMouseUp
    @sheet.socketResize {
      width: @sheet.getWH().w,
      height: @sheet.getWH().h
    }
    minimap.refresh()
