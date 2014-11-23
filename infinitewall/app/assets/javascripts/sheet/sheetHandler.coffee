define ["movable", "linkLine", "jquery"], (Movable, LinkLine, $) ->
  class GridCell extends Movable
    constructor: (sheet) ->
      super(true)
      @element = $("<div class = 'gridCell sheetBox'></div>").appendTo("#sheetLayer")
      @xywh(sheet.x, sheet.y, sheet.w, sheet.h)

    show: ->
      @element.show()

  class SheetOutline extends Movable
    constructor: (sheet) ->
      super(false)
      @element = $($("<div class = 'sheetOutline sheetBox'></div>").appendTo("#sheetLayer"))
      @xywh(sheet.x, sheet.y, sheet.w, sheet.h)

    show: ->
      @element.show()

  class SheetHandler
    sheet: null
    deltax: 0
    deltay: 0
    startx: 0
    starty: 0
    startWidth: 0
    startHeight: 0
    hasMoved: false
    myTouch: 0
    resizeType: null

    constructor: (params) ->
      @sheet = params
      @sheet.on 'resizeMouseStart', (e) => @onResizeMouseDown(e)
      @sheet.on 'resizeTouchStart', (e) => @onResizeTouchStart(e)
      @sheet.on 'moveMouseStart', (e) => @onMouseDown(e)
      @sheet.on 'moveTouchStart', (e) => @onTouchStart(e)
      @sheet.on 'mouseEnter', (e) => @onMouseEnter(e)
      @sheet.on 'mouseLeave', (e) => @onMouseLeave(e)
      @sheet.on 'doubleClick', (e) => @onMouseDblClick(e)
    
    onTouchStart: (e) =>
      console.log e
      @sheet.sheetOutline = new SheetOutline(@sheet)
      @sheet.gridCell = new GridCell(@sheet)

      stage.draggingSheet = @sheet
      @hasMoved = false
      wall.bringToTop(@sheet)
      minimap.bringToTop(stage.miniSheets[@sheet.id])

      @myTouch = e.originalEvent.touches.length - 1
      
      @hasMoved = false
      @startx = @sheet.x * stage.zoom
      @starty = @sheet.y * stage.zoom
      console.info("START_P")
      console.info(@startx, @starty)
      @deltax = e.originalEvent.touches[@myTouch].pageX
      @deltay = e.originalEvent.touches[@myTouch].pageY
      $(document).on 'touchmove', @onTouchMove
      $(document).on 'touchend', @onTouchEnd
      e.stopPropagation()

    onTouchMove: (e) =>
      @sheet.sheetOutline.show()
      @sheet.gridCell.show()
      
      @sheet.sheetOutline.x = (@startx + e.originalEvent.touches[@myTouch].pageX - @deltax) / stage.zoom
      @sheet.sheetOutline.y = (@starty + e.originalEvent.touches[@myTouch].pageY - @deltay) / stage.zoom
      @sheet.gridCell.x = (@startx + e.originalEvent.touches[@myTouch].pageX - @deltax) / stage.zoom
      @sheet.gridCell.y = (@starty + e.originalEvent.touches[@myTouch].pageY - @deltay) / stage.zoom
      @hasMoved = true

      e.preventDefault()

    onTouchEnd: (e) =>
      $(document).off 'touchmove', @onTouchMove
      $(document).off 'touchend', @onTouchEnd
      d = new Date()
      t = d.getTime()

      if @hasMoved
        moveHistObj = {x: @sheet.x, y: @sheet.y}
        @sheet.txy(@sheet.gridCell.x, @sheet.gridCell.y)
        @sheet.element.find('.sheetTextField').blur()
        @sheet.element.find('.sheetTitle').blur()
        minimap.refresh({isTransition: true})
        link.refresh(true) for id, link of @sheet.links
        @sheet.socketMove({x: @sheet.x, y: @sheet.y}, moveHistObj)
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

      @sheet.sheetOutline.element.remove()
      @sheet.sheetOutline = null
      @sheet.gridCell.element.remove()
      @sheet.gridCell = null

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

    onMouseUp: (e) =>
      stage.leftClick = false
      stage.draggingSheet = null
      wall.removeLayer.reset()
      $(document).off 'mousemove', @onMouseMove
      $(document).off 'mouseup', @onMouseUp

      if @hasMoved
        moveHistObj = {x: @sheet.x, y: @sheet.y}
        @sheet.txy(@sheet.gridCell.x, @sheet.gridCell.y)
        @sheet.socketMove({x: @sheet.x, y: @sheet.y}, moveHistObj)
        @sheet.element.find('.sheetTextField').blur()
        @sheet.element.find('.sheetTitle').blur()

        minimap.refresh({isTransition: true})
        link.refresh(true) for id, link of @sheet.links
      else
        if stage.activeSheet and stage.activeSheet isnt @sheet
          stage.activeSheet.resignActive()

        @sheet.becomeActive()
        wall.revealSheet()

      @sheet.sheetOutline.element.remove()
      @sheet.sheetOutline = null
      @sheet.gridCell.element.remove()
      @sheet.gridCell = null
      return false

    onMouseMove: (e) =>
      if stage.activeSheet is @sheet and @sheet.contentType == "textSheet"
        return false
      else
        @sheet.sheetOutline.show()
        @sheet.gridCell.show()

        @sheet.sheetOutline.x = (@startx + e.pageX - @deltax) / stage.zoom
        @sheet.sheetOutline.y = (@starty + e.pageY - @deltay) / stage.zoom
        @sheet.gridCell.x = (@startx + e.pageX - @deltax) / stage.zoom
        @sheet.gridCell.y = (@starty + e.pageY - @deltay) / stage.zoom
        @hasMoved = true

    onMouseDown: (e) =>
      if e.which is 1 # left click
        @sheet.sheetOutline = new SheetOutline(@sheet)
        @sheet.gridCell = new GridCell(@sheet)

        stage.leftClick = true
        stage.draggingSheet = @sheet
        @hasMoved = false
        wall.bringToTop(@sheet)
        minimap.bringToTop(stage.miniSheets[@sheet.id])

        @startx = @sheet.x * stage.zoom
        @starty = @sheet.y * stage.zoom

        @deltax = e.pageX
        @deltay = e.pageY

        $(document).on 'mousemove', @onMouseMove
        $(document).on 'mouseup', @onMouseUp

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
      @startWidth = @sheet.iw * stage.zoom
      @startHeight = @sheet.ih * stage.zoom
      @startx = @sheet.x * stage.zoom
      @starty = @sheet.y * stage.zoom

      @sheetPrevX = @sheet.x
      @sheetPrevY = @sheet.y
      @sheetPrevIW = @sheet.iw
      @sheetPrevIH = @sheet.ih

      @deltax = e.originalEvent.pageX
      @deltay = e.originalEvent.pageY
      @resizeType = $(e.target).attr('class').split(" ")[2]
      console.log @resizeType
      return false

    onResizeTouchEnd: (e) =>
      $(document).off 'touchmove', @onResizeTouchMove
      $(document).off 'touchend', @onResizeTouchEnd

      if @startx isnt @sheet.x or @starty isnt @sheet.y
        moveHistObj = {x: @sheetPrevX, y: @sheetPrevY}
        @sheet.socketMove({x: @sheet.x, y: @sheet.y}, moveHistObj)

      resizeHistObj = {width: @sheetPrevIW, height: @sheetPrevIH}
      @sheet.socketResize({width: @sheet.iw, height: @sheet.ih}, resizeHistObj)
      minimap.refresh()
      @resizeType = null

    onResizeMouseDown: (e) =>
      $(document).on 'mousemove', @onResizeMouseMove
      $(document).on 'mouseup', @onResizeMouseUp
      @startWidth = @sheet.iw * stage.zoom
      @startHeight = @sheet.ih * stage.zoom
      @startx = @sheet.x * stage.zoom
      @starty = @sheet.y * stage.zoom
      @sheetPrevX = @sheet.x
      @sheetPrevY = @sheet.y
      @sheetPrevIW = @sheet.iw
      @sheetPrevIH = @sheet.ih

      @deltax = e.pageX
      @deltay = e.pageY
      @resizeType = $(e.target).attr('class').split(" ")[2]
      return false

    onResizeMouseMoveSuper: (e) =>
      console.log "supersuper"
      for id, link of @sheet.links
        link.refresh()
        #TODO => 얜 왜 walnut에서 onResizeMouseMove라고 하고 override 하면 안되는가??

    onResizeMouseUp: (e) =>
      $(document).off 'mousemove', @onResizeMouseMove
      $(document).off 'mouseup', @onResizeMouseUp

      if @startx isnt @sheet.x or @starty isnt @sheet.y
        moveHistObj = {x: @sheetPrevX, y: @sheetPrevY}
        @sheet.socketMove({x: @sheet.x, y: @sheet.y}, moveHistObj)

      resizeHistObj = {width: @sheetPrevIW, height: @sheetPrevIH}
      @sheet.socketResize({width: @sheet.iw, height: @sheet.ih}, resizeHistObj)
      minimap.refresh()
      @resizeType = null

    onMouseEnter: (e) =>
      if stage.rightClick
        stage.hoverSheet = @sheet.id
        @sheet.becomeSelected()

    onMouseLeave: (e) =>
      stage.hoverSheet = null
      if not @sheet.currentLink
        @sheet.resignSelected()
