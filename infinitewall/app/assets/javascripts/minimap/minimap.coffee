class window.Minimap
  mW: null
  mCS: null
  mE: null
  mM: null
  isBoxDrag: false
  relX: 0
  relY: 0
  worldTop: 0
  worldBottom: 0
  worldLeft: 0
  worldRight: 0
  minimapRatio: 1

  constructor: () ->
    @mW = $('#minimapWorld')
    @mCS = $('#minimapCurrentScreen')
    @mE = $('#minimapElements')
    @mM = $('#miniMap')
    @mM.on 'dblclick', @onMouseDblClick
    @mM.on 'mousedown', @onMouseDown
  
  becomeSelected: () ->
    @mCS.css {
      'background-color': '#96A6D6',
      opacity: 0.5
    }
  
  resignSelected: () ->
    @mCS.css {
      'background-color': 'transparent',
      opacity: 1
    }

  refresh: (info = null) =>
    console.log info
    if !info or !info.mLx and !info.mLy
      mLx = wall.mL.x()
      mLy = wall.mL.y()
    else
      mLx = info.mLx
      mLy = info.mLy

    #좌표는 moveLayer의 기준에서 본 wall의 좌표!
    screenWidth = ($(window).width() - 225) / glob.zoomLevel
    screenHeight = ($(window).height() - 38) / glob.zoomLevel
    screenLeft = -(glob.scaleLayerXPos + mLx * glob.zoomLevel) / glob.zoomLevel
    screenTop = -(glob.scaleLayerYPos + mLy * glob.zoomLevel) / glob.zoomLevel
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
    
    if info? and info.id? # socket에서 온 경우
      for id, sheet of sheets
        if parseInt(id) is info.id
          updateWorld(info.x, info.y, info.w, info.h)
        else
          updateWorld(sheet.x(), sheet.y(), sheet.w(), sheet.h())
    else
      for id, sheet of sheets
        updateWorld(sheet.x(), sheet.y(), sheet.w(), sheet.h())

    worldWidth = @worldRight - @worldLeft
    worldHeight = @worldBottom - @worldTop
    ratio = 1

    $.fn.moveFunc = if info and info.isTransition then $.fn.transition else $.fn.css
    duration = if info and info.duration then info.duration else 400

    if (worldWidth / worldHeight) > (224 / 185)
      ratio = 224 / worldWidth
      @mW.moveFunc {
        width: 224,
        height: worldHeight * ratio,
        top: (185 - worldHeight * ratio) / 2,
        left: 0
      }, duration

    else
      ratio = 185 / worldHeight
      @mW.moveFunc {
        width: worldWidth * ratio,
        height: 185,
        top: 0,
        left: (224 - worldWidth * ratio) / 2
      }, duration

    @minimapRatio = ratio

    @mCS.moveFunc {
      width: screenWidth * ratio,
      height: screenHeight * ratio,
      top: (screenTop - @worldTop) * ratio,
      left: (screenLeft - @worldLeft) * ratio
    }, duration

    updateMiniSheet = (id, x, y, w, h) =>
      miniSheets[id].element.moveFunc {
        x: (x - @worldLeft) * ratio
        y: (y - @worldTop) * ratio
        width: w * ratio
        height: h * ratio
      }, duration

    if info? and info.id? # socket에서 온 경우
      for id, sheet of sheets
        if parseInt(id) is info.id
          updateMiniSheet(id, info.x, info.y, info.w, info.h)
        else
          updateMiniSheet(id, sheet.x(), sheet.y(), sheet.w(), sheet.h())
    else
      for id, sheet of sheets
        updateMiniSheet(id, sheet.x(), sheet.y(), sheet.w(), sheet.h())

  bringToTop: (miniSheet) ->
    @mE.append miniSheet.element

  #기준좌표는 minimapWorld의 origin

  onMouseMove: (e) =>
    mLx = wall.mL.x()
    mLy = wall.mL.y()
    mCSw = @mCS.width()
    mCSh = @mCS.height()

    tempX = e.pageX - @mW.offset().left
    tempY = e.pageY - @mW.offset().top

    if @isBoxDrag
      mouseX =
        if tempX < @relX then @relX / @minimapRatio
        else if tempX > @mW.width() - (mCSw - @relX) then (@mW.width() - (mCSw - @relX)) / @minimapRatio
        else tempX / @minimapRatio

      mouseY =
        if tempY < @relY then @relY / @minimapRatio
        else if tempY > mW.height() - (mCSh - @relY) then (@mW.height() - (mCSh - @relY)) / @minimapRatio
        else tempY / @minimapRatio

      newMoveLayerX = -((mouseX + @worldLeft - @relX / @minimapRatio) * glob.zoomLevel + glob.scaleLayerXPos) / glob.zoomLevel
      newMoveLayerY = -((mouseY + @worldTop - @relY / @minimapRatio) * glob.zoomLevel + glob.scaleLayerYPos) / glob.zoomLevel

    else
      mouseX =
        if tempX < mCSw / 2 then (mCSw / 2) / @minimapRatio
        else if tempX > @mW.width() - mCSw / 2 then (@mW.width() - mCSw / 2) / @minimapRatio
        else tempX / @minimapRatio

      mouseY =
        if tempY < mCSh / 2 then (mCSh / 2) / @minimapRatio
        else if tempY > @mW.height() - mCSh / 2 then (@mW.height() - mCSh / 2) / @minimapRatio
        else tempY / @minimapRatio

      newMoveLayerX = -((mouseX + @worldLeft - (mCSw / @minimapRatio) / 2) * glob.zoomLevel + glob.scaleLayerXPos) / glob.zoomLevel
      newMoveLayerY = -((mouseY + @worldTop - (mCSh / @minimapRatio) / 2) * glob.zoomLevel + glob.scaleLayerYPos) / glob.zoomLevel

    wall.mL.x(newMoveLayerX)
    wall.mL.y(newMoveLayerY)
    @refresh()

  onMouseUp: (e) =>
    @resignSelected()
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp

  onMouseDown: (e) =>
    mLx = wall.mL.x()
    mLy = wall.mL.y()
    mCSx = parseInt (@mCS.css 'left')
    mCSy = parseInt (@mCS.css 'top')
    mCSw = @mCS.width()
    mCSh = @mCS.height()

    @becomeSelected()

    tempX = e.pageX - @mW.offset().left
    tempY = e.pageY - @mW.offset().top

    relX = tempX - mCSx
    relY = tempY - mCSy

    isBoxDrag = if mCSx <= tempX and tempX <= mCSx + mCSw and mCSy <= tempY and tempY <= mCSy + mCSh then true else false

    if not isBoxDrag

      mouseX =
        if tempX < mCSw / 2 then (mCSw / 2) / @minimapRatio
        else if tempX > @mW.width() - mCSw / 2 then (@mW.width() - mCSw / 2) / @minimapRatio
        else tempX / @minimapRatio

      mouseY =
        if tempY < mCSh / 2 then (mCSh / 2) / @minimapRatio
        else if tempY > @mW.height() - mCSh / 2 then (@mW.height() - mCSh / 2) / @minimapRatio
        else tempY / @minimapRatio

      newMoveLayerX = -((mouseX + @worldLeft - (mCSw / @minimapRatio) / 2) * glob.zoomLevel + glob.scaleLayerXPos) / glob.zoomLevel
      newMoveLayerY = -((mouseY + @worldTop - (mCSh / @minimapRatio) / 2) * glob.zoomLevel + glob.scaleLayerYPos) / glob.zoomLevel

      $('#moveLayer').transition {
        x: newMoveLayerX
        y: newMoveLayerY
      }, 200

      @refresh {
        isTransition: true,
        mLx: newMoveLayerX,
        mLy: newMoveLayerY,
        duration: 200
      }

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    return false

  onMouseDblClick = (e) ->
    console.log "Implement me!"
    return false

