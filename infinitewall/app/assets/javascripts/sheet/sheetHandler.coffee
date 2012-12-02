class window.SheetHandler
  
  sheet: null
  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  startWidth: 0
  startHeight: 0
  hasMoved: false
  currentLink: null

  constructor: (params) ->
    @sheet = params
    @sheet.element.on 'mousedown', '.boxClose', @onButtonMouseDown
    @sheet.element.on 'mousedown', '.resizeHandle', @onResizeMouseDown
    @sheet.element.on 'mousedown', @onMouseDown
    @sheet.element.on 'mouseenter', @onMouseEnter
    @sheet.element.on 'mouseleave', @onMouseLeave
  
  onRightMouseMove: (e) =>
    if @onRightMouseMove.mouseMoved is false
      @sheet.becomeSelected()
    
    @onRightMouseMove.mouseMoved = true
    @currentLink.followMouse(e.pageX / glob.zoomLevel, (e.pageY - 38) / glob.zoomLevel)

  onRightMouseUp: (e) =>
    $(document).off 'mousemove', @onRightMouseMove
    $(document).off 'mouseup', @onRightMouseUp
    glob.rightClick = false
    @sheet.resignSelected()
    
    if glob.hoverSheet
      @currentLink.connect(glob.hoverSheet)
      sheets[glob.hoverSheet].resignSelected()

    else
      @currentLink.remove()
    
    @currentLink = null

  onMouseMove: (e) =>
    if glob.activeSheet is @sheet
      return false
    else
      newX = (@startx + e.pageX - @deltax) / glob.zoomLevel
      newY = (@starty + e.pageY - @deltay) / glob.zoomLevel
      @sheet.setXY(newX, newY)
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
      @onMouseUp.lastClick = 0 if @onMouseUp.lastClick is undefined

      if t - @onMouseUp.lastClick < 300
        console.log "doubleClick!"
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()

        wall.toCenter(@sheet)
        e.stopPropagation()

      else
        if glob.activeSheet
          if glob.activeSheet isnt @sheet
            glob.activeSheet.resignActive()
            @sheet.becomeActive()
        else
          @sheet.becomeActive()
          #newEvt = $.Event("mousedown",{
            #canBubble: true,
            #cancelable: true,
            #view: e.view,
            #detail: e.detail,
            #screenX: e.screenX,
            #screenY: e.screenY,
            #clientX: e.clientX,
            #clientY: e.clientY,
            #ctrlKey: e.ctrlKey,
            #altKey: e.altKey,
            #shiftKey: e.shiftKey,
            #metaKey: e.metaKey,
            #button: e.button,
            #relatedTarget: e.relatedTarget
          #})
          #@sheet.element.trigger(newEvt, true)
          #@sheet.element.find('.sheetTextField').trigger('activate')
        wall.revealSheet()

    @onMouseUp.lastClick = t
    return false

  onMouseDown: (e, doDefault = false) =>
    
    if not doDefault
      if e.which is 1
        @hasMoved = false
        wall.bringToTop(@sheet)
        minimap.bringToTop(miniSheets[@sheet.id])
        
        @startx = @sheet.getXY().x * glob.zoomLevel
        @starty = @sheet.getXY().y * glob.zoomLevel

        @deltax = e.pageX
        @deltay = e.pageY

        $(document).on 'mousemove', @onMouseMove
        $(document).on 'mouseup', @onMouseUp
      else if e.which is 3
        glob.rightClick = true
        @currentLink = new LinkLine(@sheet.id)
        @onRightMouseMove.mouseMoved = false
        $(document).on 'mousemove', @onRightMouseMove
        $(document).on 'mouseup', @onRightMouseUp
        return false
    
    e.stopPropagation()

  onButtonMouseDown: (e) =>
    @onButtonMouseDown.hasMoved = false
    $(document).on 'mousemove', @onButtonMouseMove
    $(document).on 'mouseup', @onButtonMouseUp
    return false

  onButtonMouseMove: (e) =>
    @onButtonMouseDown.hasMoved = true
    return false
  
  onButtonMouseUp: (e) =>
    @sheet.socketRemove() if not @onButtonMouseDown.hasMoved
    $(document).off 'mousemove', @onButtonMouseMove
    $(document).off 'mouseup', @onButtonMouseUp
  
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

  onMouseEnter: (e) =>
    if glob.rightClick
      glob.hoverSheet = @sheet.id
      @sheet.becomeSelected()

  onMouseLeave: (e) =>
    glob.hoverSheet = null
    if not @currentLink
      @sheet.resignSelected()
