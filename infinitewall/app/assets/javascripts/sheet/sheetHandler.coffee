class window.SheetHandler
  sheet: null
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
  
  onTouchStart: (e) =>
    console.log "touchstart"
    wall.bringToTop(@sheet)
    minimap.bringToTop(miniSheets[@sheet.id])

    @myTouch = e.originalEvent.touches.length - 1
    
    @hasMoved = false
    @startx = @sheet.x() * glob.zoomLevel
    @starty = @sheet.y() * glob.zoomLevel
    @deltax = e.originalEvent.touches[@myTouch].pageX
    @deltay = e.originalEvent.touches[@myTouch].pageY
    $(document).on 'touchmove', @onTouchMove
    $(document).on 'touchend', @onTouchEnd
    e.stopPropagation()

  onTouchMove: (e) =>
    @sheet.x((@startx + e.originalEvent.touches[@myTouch].pageX - @deltax) / glob.zoomLevel)
    @sheet.y((@starty + e.originalEvent.touches[@myTouch].pageY - @deltay) / glob.zoomLevel)
    @hasMoved = true
    e.preventDefault()
      
  onTouchEnd: (e) =>
    $(document).off 'touchmove', @onTouchMove
    $(document).off 'touchend', @onTouchEnd
    d = new Date()
    t = d.getTime()
    
    minimap.refresh()

    if @hasMoved
      @sheet.socketMove {
        x: @sheet.x()
        y: @sheet.y()
      }
      @sheet.element.find('.sheetTextField').blur()
      @sheet.element.find('.sheetTitle').blur()

    else
      @onTouchEnd.lastTouch = @onTouchEnd.lastTouch || 0

      if t - @onTouchEnd.lastTouch < 300
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()

        wall.toCenter(@sheet)
        @onTouchEnd.lastTouch = 0

      else
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()
        else
          @sheet.becomeActive()
        wall.revealSheet()
        @onTouchEnd.lastTouch = t

    return false

  onRightMouseMove: (e) =>
    @sheet.becomeSelected() if not @onRightMouseMove.mouseMoved
    @onRightMouseMove.mouseMoved = true
    @sheet.currentLink.followMouse(e.pageX / glob.zoomLevel, e.pageY / glob.zoomLevel)

    offset = 10

    if e.pageY > $(window).height() - 70
      moveFunc = => wall.mL.y(wall.mL.y() - offset / glob.zoomLevel)
    else if e.pageY < 70
      moveFunc = => wall.mL.y(wall.mL.y() + offset / glob.zoomLevel)
    else if e.pageX > $(window).width() - 70
      moveFunc = => wall.mL.x(wall.mL.x() - offset / glob.zoomLevel)
    else if e.pageX < 140
      moveFunc = => wall.mL.x(wall.mL.x() + offset / glob.zoomLevel)
    else
      clearInterval(glob.moveID)
      glob.moveID = null
      return

    timedMove = =>
      moveFunc()
      #glob.linkFromSheet.currentLink.followMouse(e.pageX / glob.zoomLevel, e.pageY / glob.zoomLevel)
      minimap.refresh()
    
    glob.moveID = setInterval(timedMove, 30) unless glob.moveID?

    #console.log e

  onRightMouseUp: (e) =>
    $(document).off 'mousemove', @onRightMouseMove
    $(document).off 'mouseup', @onRightMouseUp
    clearInterval(glob.moveID)
    glob.moveID = null
    glob.rightClick = false
    @sheet.resignSelected()
    
    if glob.hoverSheet
      if @sheet.links[glob.hoverSheet]?
        @sheet.socketRemoveLink(glob.hoverSheet)
      else if @sheet.id != glob.hoverSheet
        @sheet.socketSetLink(glob.hoverSheet)
      @sheet.currentLink.remove()
      sheets[glob.hoverSheet].resignSelected()
    else
      @sheet.currentLink.remove()
    @sheet.currentLink = null

  onMouseMove: (e) =>
    if glob.activeSheet is @sheet
      return false
    else
      @sheet.x((@startx + e.pageX - @deltax) / glob.zoomLevel)
      @sheet.y((@starty + e.pageY - @deltay) / glob.zoomLevel)
      @hasMoved = true
      minimap.refresh()
      
      for id, link of @sheet.links
        link.refresh()
   
  onMouseUp: (e) =>
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    d = new Date()
    t = d.getTime()

    if @hasMoved
      @sheet.socketMove {
        x: (@startx + e.pageX - @deltax) / glob.zoomLevel,
        y: (@starty + e.pageY - @deltay) / glob.zoomLevel
      }
      @sheet.element.find('.sheetTextField').blur()
      @sheet.element.find('.sheetTitle').blur()
    else
      @onMouseUp.lastClick = @onMouseUp.lastClick || 0

      if t - @onMouseUp.lastClick < 300
        console.log "doubleClick!"
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()

        wall.toCenter(@sheet)

      else
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()
        else
          @sheet.becomeActive()
        wall.revealSheet()

    @onMouseUp.lastClick = t
    return false

  onMouseDown: (e) =>
    if e.which is 1 # left click
      @hasMoved = false
      wall.bringToTop(@sheet)
      minimap.bringToTop(miniSheets[@sheet.id])

      @startx = @sheet.x() * glob.zoomLevel
      @starty = @sheet.y() * glob.zoomLevel

      @deltax = e.pageX
      @deltay = e.pageY

      $(document).on 'mousemove', @onMouseMove
      $(document).on 'mouseup', @onMouseUp

    else if e.which is 3 # right click
      glob.rightClick = true
      glob.linkFromSheet = @sheet
      @sheet.currentLink = new LinkLine(@sheet.id)
      @onRightMouseMove.mouseMoved = false
      $(document).on 'mousemove', @onRightMouseMove
      $(document).on 'mouseup', @onRightMouseUp
      return false

    e.stopPropagation()

  onResizeTouchStart: (e) =>
    $(document).on 'touchmove', @onResizeTouchMove
    $(document).on 'touchend', @onResizeTouchEnd
    console.log "resizetouchstart"
    @startWidth = @sheet.iw() * glob.zoomLevel
    @startHeight = @sheet.ih() * glob.zoomLevel
    @deltax = e.originalEvent.pageX
    @deltay = e.originalEvent.pageY
    return false

  onResizeTouchEnd: (e) =>
    $(document).off 'touchmove', @onResizeTouchMove
    $(document).off 'touchend', @onResizeTouchEnd

    @sheet.socketResize {
      width: @sheet.iw()
      height: @sheet.ih()
    }
    minimap.refresh()

  onResizeMouseDown: (e) =>
    $(document).on 'mousemove', @onResizeMouseMove
    $(document).on 'mouseup', @onResizeMouseUp
    @startWidth = @sheet.iw() * glob.zoomLevel
    @startHeight = @sheet.ih() * glob.zoomLevel
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
      width: @sheet.iw(),
      height: @sheet.ih()
    }
    minimap.refresh()

  onMouseEnter: (e) =>
    if glob.rightClick
      glob.hoverSheet = @sheet.id
      @sheet.becomeSelected()

  onMouseLeave: (e) =>
    glob.hoverSheet = null
    if not @sheet.currentLink
      @sheet.resignSelected()
