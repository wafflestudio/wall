class MiniSheet extends Movable
  constructor: (params) ->
    @id = params.id
    @element = $($('<div class = "miniSheet"></div>').appendTo('#miniMoveLayer'))
    #@xywh(params.x, params.y, params.width, params.height)
    @element.attr('id', 'map_sheet' + @id)
    @element.on 'mousedown', @onMouseDown
    
  becomeActive: =>
    @element.addClass("activeMiniSheet")

  resignActive: =>
    @element.removeClass("activeMiniSheet")

  becomeSelected: =>
    @element.addClass("selectedMiniSheet")

  resignSelected: =>
    @element.removeClass("selectedMiniSheet")

  remove: ->
    @element.remove()

  onMouseDown: (e) =>
    @becomeSelected()
    sheet = stage.sheets[@id]
    wall.center(sheet, @resignSelected)
    return false

class Miniworld extends Movable
  constructor: -> @element = $("#minimapWorld")

class Miniscreen extends Movable
  constructor: -> @element = $("#miniScreen")

  becomeSelected: ->
    @element.addClass("selectedMiniScreen")
  
  resignSelected: ->
    @element.removeClass("selectedMiniScreen")

class window.Minimap extends Movable
  miniWorld: null
  miniScreen: null
  mE: null
  isBoxDrag: false
  isToggled: true
  relX: 0
  relY: 0
  worldTop: 0
  worldBottom: 0
  worldLeft: 0
  worldRight: 0
  ratio: 1
  minimapWidth: 0
  minimapHeight: 0

  constructor: ->
    @element = $('#minimap')
    @miniWorld = new Miniworld()
    @miniScreen = new Miniscreen()
    @mML = $('#miniMoveLayer')
    @element.on 'mousedown', @onMouseDown
    @element.on 'touchstart', @onTouchStart
    @minimapWidth = @w
    @minimapHeight = @h

  stopTransitioning: ->
    @miniWorld.element.clearQueue()
    @miniScreen.element.clearQueue()

    minisheet.element.clearQueue() for id, minisheet of stage.miniSheets

  createMiniSheet: (params) -> new MiniSheet(params)
  
  toggle: -> @element.fadeToggle()

  refresh: (info = {}) =>
    mLx = info.mLx || wall.mL.x
    mLy = info.mLy || wall.mL.y

    #좌표는 moveLayer의 기준에서 본 wall의 좌표!
    screenWidth = ($(window).width()) / stage.zoom
    screenHeight = ($(window).height()) / stage.zoom
    screenLeft = -(stage.scaleLayerX + mLx * stage.zoom) / stage.zoom
    screenTop = -(stage.scaleLayerY + mLy * stage.zoom) / stage.zoom
    screenRight = screenLeft + screenWidth
    screenBottom = screenTop + screenHeight

    @worldTop = screenTop
    @worldBottom = screenBottom
    @worldLeft = screenLeft
    @worldRight = screenRight
    
    updateWorld = (sheetX, sheetY, sheetW, sheetH) =>
      @worldLeft = sheetX if sheetX < @worldLeft
      @worldRight = sheetX + sheetW if sheetX + sheetW > @worldRight
      @worldTop = sheetY if sheetY < @worldTop
      @worldBottom = sheetY + sheetH if sheetY + sheetH > @worldBottom
    
    if info.id? # socket에서 온 경우
      for id, sheet of stage.sheets
        if parseInt(id) is info.id
          updateWorld(info.x, info.y, info.w, info.h)
        else
          updateWorld(sheet.x, sheet.y, sheet.w, sheet.h)
    else
      for id, sheet of stage.sheets
        updateWorld(sheet.x, sheet.y, sheet.w, sheet.h)

    worldWidth = @worldRight - @worldLeft
    worldHeight = @worldBottom - @worldTop
    @ratio = 1

    isTransition = info.isTransition || false
    duration = info.duration || 400

    if (worldWidth / worldHeight) > (@minimapWidth / @minimapHeight)
      @ratio = @minimapWidth / worldWidth
      if isTransition
        @miniWorld.txywh(0, (@minimapHeight - worldHeight * @ratio) / 2, @minimapWidth, worldHeight * @ratio, duration)
      else
        @miniWorld.xywh(0, (@minimapHeight - worldHeight * @ratio) / 2, @minimapWidth, worldHeight * @ratio)

    else
      @ratio = @minimapHeight / worldHeight
      if isTransition
        @miniWorld.txywh((@minimapWidth - worldWidth * @ratio) / 2, 0, worldWidth * @ratio, @minimapHeight, duration)
      else
        @miniWorld.xywh((@minimapWidth - worldWidth * @ratio) / 2, 0, worldWidth * @ratio, @minimapHeight)

    if isTransition
      @miniScreen.txywh((screenLeft - @worldLeft) * @ratio, (screenTop - @worldTop) * @ratio, screenWidth * @ratio, screenHeight * @ratio, duration)
    else
      @miniScreen.xywh((screenLeft - @worldLeft) * @ratio, (screenTop - @worldTop) * @ratio, screenWidth * @ratio, screenHeight * @ratio)

    updateMiniSheet = (id, x, y, w, h) =>
      if isTransition
        stage.miniSheets[id].txywh((x - @worldLeft) * @ratio, (y - @worldTop) * @ratio, w * @ratio, h * @ratio, duration)
      else
        stage.miniSheets[id].xywh((x - @worldLeft) * @ratio, (y - @worldTop) * @ratio, w * @ratio, h * @ratio)

    if info.id? # socket에서 온 경우
      for id, sheet of stage.sheets
        if parseInt(id) is info.id
          updateMiniSheet(id, info.x, info.y, info.w, info.h)
        else
          updateMiniSheet(id, sheet.x, sheet.y, sheet.w, sheet.h)
    else
      for id, sheet of stage.sheets
        updateMiniSheet(id, sheet.x, sheet.y, sheet.w, sheet.h)

  bringToTop: (miniSheet) ->
    @mML.append miniSheet.element

  #기준좌표는 minimapWorld의 origin

  onMouseMove: (e) =>
    tempX = e.pageX - @miniWorld.element.offset().left
    tempY = e.pageY - @miniWorld.element.offset().top

    if @isBoxDrag # 얘를 해야 박스의 코너를 잡고 움직여도 제대로 움직임
      mouseX =
        if tempX < @relX then @relX / @ratio
        else if tempX > @miniWorld.w - (@miniScreen.w - @relX) then (@miniWorld.w - (@miniScreen.w - @relX)) / @ratio
        else tempX / @ratio

      mouseY =
        if tempY < @relY then @relY / @ratio
        else if tempY > @miniWorld.h - (@miniScreen.h - @relY) then (@miniWorld.h - (@miniScreen.h - @relY)) / @ratio
        else tempY / @ratio

      newMoveLayerX = -((mouseX + @worldLeft - @relX / @ratio) * stage.zoom + stage.scaleLayerX) / stage.zoom
      newMoveLayerY = -((mouseY + @worldTop - @relY / @ratio) * stage.zoom + stage.scaleLayerY) / stage.zoom

    else
      mouseX =
        if tempX < @miniScreen.w / 2 then (@miniScreen.w / 2) / @ratio
        else if tempX > @miniWorld.w - @miniScreen.w / 2 then (@miniWorld.w - @miniScreen.w / 2) / @ratio
        else tempX / @ratio

      mouseY =
        if tempY < @miniScreen.h / 2 then (@miniScreen.h / 2) / @ratio
        else if tempY > @miniWorld.h - @miniScreen.h / 2 then (@miniWorld.h - @miniScreen.h / 2) / @ratio
        else tempY / @ratio

      newMoveLayerX = -((mouseX + @worldLeft - (@miniScreen.w / @ratio) / 2) * stage.zoom + stage.scaleLayerX) / stage.zoom
      newMoveLayerY = -((mouseY + @worldTop - (@miniScreen.h / @ratio) / 2) * stage.zoom + stage.scaleLayerY) / stage.zoom

    wall.mL.smoothmove(newMoveLayerX, newMoveLayerY)
    #wall.mL.x = newMoveLayerX
    #wall.mL.y = newMoveLayerY

    @refresh()
    e.preventDefault()

  onMouseUp: (e) =>
    @miniScreen.resignSelected()
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp

  onMouseDown: (e) =>
    @miniScreen.becomeSelected()
    clearTimeout(wall.mL.timer)

    #stage.zoom = 1
    #wall.sL.setZoom()

    tempX = e.pageX - @miniWorld.element.offset().left
    tempY = e.pageY - @miniWorld.element.offset().top

    @relX = tempX - @miniScreen.x
    @relY = tempY - @miniScreen.y

    mouseX =
      if tempX < @miniScreen.w / 2 then (@miniScreen.w / 2) / @ratio
      else if tempX > @miniWorld.w - @miniScreen.w / 2 then (@miniWorld.w - @miniScreen.w / 2) / @ratio
      else tempX / @ratio

    mouseY =
      if tempY < @miniScreen.h / 2 then (@miniScreen.h / 2) / @ratio
      else if tempY > @miniWorld.h - @miniScreen.h / 2 then (@miniWorld.h - @miniScreen.h / 2) / @ratio
      else tempY / @ratio

    newMoveLayerX = -((mouseX + @worldLeft - (@miniScreen.w / @ratio) / 2) * stage.zoom + stage.scaleLayerX) / stage.zoom
    newMoveLayerY = -((mouseY + @worldTop - (@miniScreen.h / @ratio) / 2) * stage.zoom + stage.scaleLayerY) / stage.zoom

    #wall.center({x: newMoveLayerX, y: newMoveLayerY})

    wall.mL.txy(newMoveLayerX, newMoveLayerY, 200)

    @refresh {
      isTransition: true
      mLx: newMoveLayerX
      mLy: newMoveLayerY
      duration: 200
    }

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    return false

  onTouchStart: (e) ->
    @miniScreen.becomeSelected()

    tempX = e.originalEvent.pageX - @miniWorld.element.offset().left
    tempY = e.originalEvent.pageY - @miniWorld.element.offset().top

    @relX = tempX - @miniScreen.x
    @relY = tempY - @miniScreen.y

    @isBoxDrag = @miniScreen.left <= tempX <= @miniScreen.right and @miniScreen.top <= tempY <= @miniScreen.bottom

    if not @isBoxDrag
      mouseX =
        if tempX < @miniScreen.w / 2 then (@miniScreen.w / 2) / @ratio
        else if tempX > @miniWorld.w - @miniScreen.w / 2 then (@miniWorld.w - @miniScreen.w / 2) / @ratio
        else tempX / @ratio

      mouseY =
        if tempY < @miniScreen.h / 2 then (@miniScreen.h / 2) / @ratio
        else if tempY > @miniWorld.h - @miniScreen.h / 2 then (@miniWorld.h - @miniScreen.h / 2) / @ratio
        else tempY / @ratio

      newMoveLayerX = -((mouseX + @worldLeft - (@miniScreen.w / @ratio) / 2) * stage.zoom + stage.scaleLayerX) / stage.zoom
      newMoveLayerY = -((mouseY + @worldTop - (@miniScreen.h / @ratio) / 2) * stage.zoom + stage.scaleLayerY) / stage.zoom

      wall.mL.txy(newMoveLayerX, newMoveLayerY, 200)

      @refresh {
        isTransition: true
        mLx: newMoveLayerX
        mLy: newMoveLayerY
        duration: 200
      }

    $(document).on 'touchmove', @onTouchMove
    $(document).on 'touchend', @onTouchEnd
    return false

  onTouchMove: (e) =>
    return false

  onTouchEnd: (e) =>
    @miniScreen.resignSelected()
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
