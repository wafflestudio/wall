class GridCell extends Movable
  constructor: (sheet) ->
    super(true)
    @element = $($("<div class = 'gridCell'></div>").appendTo("#sheetLayer"))
    @xywh(sheet.x, sheet.y, sheet.w, sheet.h)

class SheetOutline extends Movable
  constructor: (sheet) ->
    super(false)
    @element = $($("<div class = 'sheetOutline'></div>").appendTo("#sheetLayer"))
    @xywh(sheet.x, sheet.y, sheet.w, sheet.h)

class window.SheetHandler
  sheet: null
  sheetOutline: null
  gridCell: null
  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  startWidth: 0
  startHeight: 0
  hasMoved: false
  myTouch: 0

  constructor: (params) ->
    @sheet = params
    @sheet.element.on 'mousedown', '.resizeHandle', @onResizeMouseDown
    @sheet.element.on 'touchstart', '.resizeHandle', @onResizeTouchStart
    @sheet.element.on 'mousedown', @onMouseDown
    @sheet.element.on 'touchstart', @onTouchStart
    @sheet.element.on 'mouseenter', @onMouseEnter
    @sheet.element.on 'mouseleave', @onMouseLeave
    @sheet.element.on 'dblclick', @onMouseDblClick
  
  onTouchStart: (e) =>
    wall.bringToTop(@sheet)
    minimap.bringToTop(stage.miniSheets[@sheet.id])

    @myTouch = e.originalEvent.touches.length - 1
    
    @hasMoved = false
    @startx = @sheet.x * stage.zoom
    @starty = @sheet.y * stage.zoom
    @deltax = e.originalEvent.touches[@myTouch].pageX
    @deltay = e.originalEvent.touches[@myTouch].pageY
    $(document).on 'touchmove', @onTouchMove
    $(document).on 'touchend', @onTouchEnd
    e.stopPropagation()

  onTouchMove: (e) =>
    @sheet.x = (@startx + e.originalEvent.touches[@myTouch].pageX - @deltax) / stage.zoom
    @sheet.y = (@starty + e.originalEvent.touches[@myTouch].pageY - @deltay) / stage.zoom
    @hasMoved = true
    for id, link of @sheet.links
      link.refresh()
    e.preventDefault()
      
  onTouchEnd: (e) =>
    $(document).off 'touchmove', @onTouchMove
    $(document).off 'touchend', @onTouchEnd
    d = new Date()
    t = d.getTime()
    
    minimap.refresh()

    if @hasMoved
      @sheet.socketMove {
        x: @sheet.x
        y: @sheet.y
      }
      @sheet.element.find('.sheetTextField').blur()
      @sheet.element.find('.sheetTitle').blur()

    else
      @onTouchEnd.lastTouch = @onTouchEnd.lastTouch || 0

      if t - @onTouchEnd.lastTouch < 300
        if stage.activeSheet
          if stage.activeSheet isnt @sheet
            stage.activeSheet.resignActive()
            @sheet.becomeActive()

        wall.center(@sheet)
        @onTouchEnd.lastTouch = 0

      else
        if stage.activeSheet
          if stage.activeSheet isnt @sheet
            stage.activeSheet.resignActive()
            @sheet.becomeActive()
        else
          @sheet.becomeActive()
        wall.revealSheet()
        @onTouchEnd.lastTouch = t

    return false

  onRightMouseMove: (e) =>
    @sheet.becomeSelected() if not @onRightMouseMove.mouseMoved
    @onRightMouseMove.mouseMoved = true
    @sheet.currentLink.followMouse(e.pageX / stage.zoom, e.pageY / stage.zoom)

    offset = 10

    if e.pageY > $(window).height() - 70
      moveFunc = => wall.mL.y = (wall.mL.y - offset / stage.zoom)
    else if e.pageY < 70
      moveFunc = => wall.mL.y = (wall.mL.y + offset / stage.zoom)
    else if e.pageX > $(window).width() - 70
      moveFunc = => wall.mL.x = (wall.mL.x - offset / stage.zoom)
    else if e.pageX < 140
      moveFunc = => wall.mL.x = (wall.mL.x + offset / stage.zoom)
    else
      clearInterval(stage.moveID)
      stage.moveID = null
      return

    timedMove = =>
      moveFunc()
      #stage.linkFromSheet.currentLink.followMouse(e.pageX / stage.zoom, e.pageY / stage.zoom)
      minimap.refresh()
    
    stage.moveID = setInterval(timedMove, 30) unless stage.moveID?

    #console.log e

  onRightMouseUp: (e) =>
    $(document).off 'mousemove', @onRightMouseMove
    $(document).off 'mouseup', @onRightMouseUp
    clearInterval(stage.moveID)
    stage.moveID = null
    stage.rightClick = false
    @sheet.resignSelected()
    
    if stage.hoverSheet
      if @sheet.links[stage.hoverSheet]?
        @sheet.socketRemoveLink(stage.hoverSheet)
      else if @sheet.id isnt stage.hoverSheet
        @sheet.socketSetLink(stage.hoverSheet)
      @sheet.currentLink.remove()
      stage.sheets[stage.hoverSheet].resignSelected()
    else
      @sheet.currentLink.remove()
    @sheet.currentLink = null

  onMouseMove: (e) =>
    if stage.activeSheet is @sheet and @sheet.contentType is stage.contentTypeEnum.text
      return false
    else
      @sheet.x = (@startx + e.pageX - @deltax) / stage.zoom
      @sheet.y = (@starty + e.pageY - @deltay) / stage.zoom
      @hasMoved = true
      minimap.refresh()

      for id, link of @sheet.links
        link.refresh()
   
  onMouseUp: (e) =>
    stage.leftClick = false
    stage.draggingSheet = null
    wall.removeLayer.reset()
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    @sheetOutline.element.remove()
    @sheetOutline = null

    if @hasMoved
      @sheet.socketMove {
        x: @sheet.x
        y: @sheet.y
      }
      @sheet.element.find('.sheetTextField').blur()
      @sheet.element.find('.sheetTitle').blur()
    else
      if stage.activeSheet and stage.activeSheet isnt @sheet
        stage.activeSheet.resignActive()

      @sheet.becomeActive()
      wall.revealSheet()

    return false

  onMouseUpTwo: (e) =>
    stage.leftClick = false
    stage.draggingSheet = null
    wall.removeLayer.reset()
    $(document).off 'mousemove', @onMouseMoveTwo
    $(document).off 'mouseup', @onMouseUpTwo

    console.log @sheetOutline.x
    console.log @sheetOutline.y

    if @hasMoved
      @sheet.txy(@sheetOutline.x, @sheetOutline.y)

      @sheet.socketMove {
        x: @sheet.x
        y: @sheet.y
      }
      @sheet.element.find('.sheetTextField').blur()
      @sheet.element.find('.sheetTitle').blur()
    else
      if stage.activeSheet and stage.activeSheet isnt @sheet
        stage.activeSheet.resignActive()

      @sheet.becomeActive()
      wall.revealSheet()

    @sheetOutline.element.remove()
    @sheetOutline = null
    @gridCell.element.remove()
    @gridCell = null
    return false

  onMouseMoveTwo: (e) =>
    if stage.activeSheet is @sheet and @sheet.contentType is stage.contentTypeEnum.text
      return false
    else
      @sheetOutline.x = (@startx + e.pageX - @deltax) / stage.zoom
      @sheetOutline.y = (@starty + e.pageY - @deltay) / stage.zoom
      @gridCell.x = (@startx + e.pageX - @deltax) / stage.zoom
      @gridCell.y = (@starty + e.pageY - @deltay) / stage.zoom
      @hasMoved = true

  onMouseDown: (e) =>
    if e.which is 1 # left click
      @sheetOutline = new SheetOutline(@sheet)
      @gridCell = new GridCell(@sheet)

      stage.leftClick = true
      stage.draggingSheet = @sheet
      @hasMoved = false
      wall.bringToTop(@sheet)
      minimap.bringToTop(stage.miniSheets[@sheet.id])

      @startx = @sheet.x * stage.zoom
      @starty = @sheet.y * stage.zoom

      @deltax = e.pageX
      @deltay = e.pageY

      $(document).on 'mousemove', @onMouseMoveTwo
      $(document).on 'mouseup', @onMouseUpTwo
      #$(document).on 'mousemove', @onMouseMove
      #$(document).on 'mouseup', @onMouseUp

    else if e.which is 3 # right click
      stage.rightClick = true
      stage.linkFromSheet = @sheet
      @sheet.currentLink = new LinkLine(@sheet.id)
      @onRightMouseMove.mouseMoved = false
      $(document).on 'mousemove', @onRightMouseMove
      $(document).on 'mouseup', @onRightMouseUp
      return false

    e.stopPropagation()

  onMouseDblClick: (e) =>
    if stage.activeSheet and stage.activeSheet isnt @sheet
      stage.activeSheet.resignActive()

    @sheet.becomeActive()
    wall.mL.stopTransitioning()
    minimap.stopTransitioning()
    wall.center(@sheet)

  onResizeTouchStart: (e) =>
    $(document).on 'touchmove', @onResizeTouchMove
    $(document).on 'touchend', @onResizeTouchEnd
    console.log "resizetouchstart"
    @startWidth = @sheet.iw * stage.zoom
    @startHeight = @sheet.ih * stage.zoom
    @deltax = e.originalEvent.pageX
    @deltay = e.originalEvent.pageY
    return false

  onResizeTouchEnd: (e) =>
    $(document).off 'touchmove', @onResizeTouchMove
    $(document).off 'touchend', @onResizeTouchEnd

    @sheet.socketResize {
      width: @sheet.iw
      height: @sheet.ih
    }
    minimap.refresh()

  onResizeMouseDown: (e) =>
    $(document).on 'mousemove', @onResizeMouseMove
    $(document).on 'mouseup', @onResizeMouseUp
    @startWidth = @sheet.iw * stage.zoom
    @startHeight = @sheet.ih * stage.zoom
    @deltax = e.pageX
    @deltay = e.pageY
    return false

  onResizeMouseMove: (e) =>
    for id, link of @sheet.links
      link.refresh()

  onResizeMouseUp: (e) =>
    $(document).off 'mousemove', @onResizeMouseMove
    $(document).off 'mouseup', @onResizeMouseUp

    @sheet.socketResize {
      width: @sheet.iw
      height: @sheet.ih
    }
    minimap.refresh()

  onMouseEnter: (e) =>
    if stage.rightClick
      stage.hoverSheet = @sheet.id
      @sheet.becomeSelected()

  onMouseLeave: (e) =>
    stage.hoverSheet = null
    if not @sheet.currentLink
      @sheet.resignSelected()
