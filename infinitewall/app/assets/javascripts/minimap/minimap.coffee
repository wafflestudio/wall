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

  refresh: (callInfo = null) =>
    if !callInfo or !callInfo.mLx and !callInfo.mLy
      mLx = wall.getMLxy().x
      mLy = wall.getMLxy().y
    else
      mLx = callInfo.mLx
      mLy = callInfo.mLy

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

    updateWorldSize = (sheet) =>
      sheetX = sheet.getXY().x
      sheetY = sheet.getXY().y
      sheetW = sheet.getOuterWH().w
      sheetH = sheet.getOuterWH().h

      @worldLeft = sheetX if sheetX < @worldLeft
      @worldRight = sheetX + sheetW if sheetX + sheetW > @worldRight
      @worldTop = sheetY if sheetY < @worldTop
      @worldBottom = sheetY + sheetH if sheetY + sheetH > @worldBottom
   
    for id, obj of sheets
      updateWorldSize obj

    worldWidth = @worldRight - @worldLeft
    worldHeight = @worldBottom - @worldTop
    ratio = 1
    
    $.fn.moveFunc = if callInfo and callInfo.isTransition then $.fn.transition else $.fn.css
    duration = if callInfo and callInfo.duration then callInfo.duration else 400

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
    
    shrinkMiniSheet = (id, sheet) =>
      newX = (sheet.getXY().x - @worldLeft) * ratio
      newY = (sheet.getXY().y - @worldTop) * ratio
      newW = sheet.getOuterWH().w * ratio
      newH = sheet.getOuterWH().h * ratio
      
      mS = miniSheets[id]
      #mS.setXY(newX, newY, $.fn.moveFunc, duration)
      #mS.setWH(newW, newH, $.fn.moveFunc, duration)
      mS.element.moveFunc {
        x: newX,
        y: newY,
        width: newW,
        height: newH
      }, duration

    for id, obj of sheets
      shrinkMiniSheet(id, obj)

  bringToTop: (miniSheet) ->
    @mE.append miniSheet.element

  element = $('#miniMap')

  #기준좌표는 minimapWorld의 origin

  onMouseMove: (e) =>
    mLx = wall.getMLxy().x
    mLy = wall.getMLxy().y
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

    wall.setMLxy(newMoveLayerX, newMoveLayerY)
    @refresh()
  
  onMouseUp: (e) =>
    @resignSelected()
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp

  onMouseDown: (e) =>

    mLx = wall.getMLxy().x
    mLy = wall.getMLxy().y
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

