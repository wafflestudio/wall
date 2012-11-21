class window.Wall
  wall: null
  mL: null
  sL: null
  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  xScaleLayer: 0
  yScaleLayer: 0
  xWallLast: 0
  yWallLast: 0
  hasMoved: false
  
  bringToTop: (sheet) ->
    @mL.append sheet.element

  setSL: (tx, ty, x, y, isTransition = false) ->
    @sL.css {
      transformOrigin: tx + 'px ' + ty + 'px',
      x: x,
      y: y
    }
    if isTransition
      @sL.transition {scale: glob.zoomLevel}
    else
      @sL.css {scale: glob.zoomLevel}

  setMLxy: (x, y) ->
    @mL.css {x: x, y: y}

  getMLxy: () ->
    x: parseInt(@mL.css('x'))
    y: parseInt(@mL.css('y'))

  #screenWidth: ($(window).width() - 225) / glob.zoomLevel
  #screenHeight: ($(window).height() - 38) / glob.zoomLevel
  #screenTop: -(glob.scaleLayerYPos + @getMLxy().y * glob.zoomLevel) / glob.zoomLevel
  #screenLeft: -(glob.scaleLayerXPos + @getMLxy().x * glob.zoomLevel) / glob.zoomLevel

  constructor: () ->
    @wall = $('#wall')
    @mL = $('#moveLayer')
    @sL = $('#scaleLayer')
    @wall.on 'dblclick', @onMouseDblClick
    @wall.on 'mousedown', @onMouseDown
    @wall.on 'mousewheel', @onMouseWheel

  onMouseMove: (e) =>
    newX = (@startx + e.pageX - @deltax) / glob.zoomLevel
    newY = (@starty + e.pageY - @deltay) / glob.zoomLevel
    @setMLxy(newX, newY)
    @hasMoved = true
    minimap.refresh()

  onMouseUp: ->
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp

    if glob.activeSheet and not @hasMoved
      glob.activeSheet.resignActive()
  
  onMouseDown: (e) =>
    @hasMoved = false
    @startx = @getMLxy().x * glob.zoomLevel
    @starty = @getMLxy().y * glob.zoomLevel
    @deltax = e.pageX
    @deltay = e.pageY

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    e.preventDefault()

  onMouseWheel: (e, delta, deltaX, deltaY) =>

    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top - 38

    #-38은 #wall이 위에 네비게이션 바 밑으로 들어간 38픽셀에 대한 compensation
    #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

    @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
    @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
    
    #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
    #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
    
    glob.zoomLevel += delta / 2.5
    glob.zoomLevel = if glob.zoomLevel < 0.25 then 0.25 else (if glob.zoomLevel > 1 then 1 else glob.zoomLevel)
        
    xNew = (xWall - @xScaleLayer) / glob.zoomLevel
    yNew = (yWall - @yScaleLayer) / glob.zoomLevel
    
    #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
    
    @xWallLast = xWall
    @yWallLast = yWall

    glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
    glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel

    #scaleLayer의 좌표를 wall의 기준으로 저장

    @setSL(@xScaleLayer, @yScaleLayer, xNew, yNew)

    $('.boxClose').css {scale: 1 / glob.zoomLevel}
    $('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")

    minimap.refresh()
    return false

  onMouseDblClick: (e) =>
    
    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top - 38

    @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
    @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
    
    glob.zoomLevel = if glob.zoomLevel is 1 then 0.25 else 1
   
    if glob.zoomLevel is 1
      xNew = (xWall - @xScaleLayer) / glob.zoomLevel
      yNew = (yWall - @yScaleLayer) / glob.zoomLevel
    
    @xWallLast = xWall
    @yWallLast = yWall

    glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
    glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel

    @setSL(xWall, yWall, xNew, yNew, true)

    $('.boxClose').transition {scale: 1 / glob.zoomLevel}
    $('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
    minimap.refresh {isTransition: true}
    return false

  revealSheet: ->

    #좌표는 moveLayer의 기준에서 본 wall의 좌표!
    screenWidth = ($(window).width() - 225) / glob.zoomLevel
    screenHeight = ($(window).height() - 38) / glob.zoomLevel
    screenTop = -(glob.scaleLayerYPos + @getMLxy().y * glob.zoomLevel) / glob.zoomLevel
    screenLeft = -(glob.scaleLayerXPos + @getMLxy().x * glob.zoomLevel) / glob.zoomLevel

    sheet = glob.activeSheet
    sheetWidth = sheet.getWH().w
    sheetHeight = sheet.getWH().h
    sheetX = sheet.getXY().x
    sheetY = sheet.getXY().y

    if ((sheetX < screenLeft) or (sheetX + sheetWidth > screenLeft + screenWidth) or (sheetY < screenTop) or (sheetY + sheetHeight > screenTop + screenHeight))
      
      diffX = 0
      diffY = 0
      offset = 35

      if (sheetX < screenLeft)
        diffX = screenLeft - sheetX + offset
      if (sheetX + sheetWidth > screenLeft + screenWidth)
        diffX = (screenLeft + screenWidth) - (sheetX + sheetWidth + offset)
      if (sheetY < screenTop)
        diffY = screenTop - sheetY + offset
      if (sheetY + sheetHeight > screenTop + screenHeight)
        diffY = screenTop + screenHeight - (sheetY + sheetHeight + offset)
      
      moveLayerX = @getMLxy().x
      moveLayerY = @getMLxy().y

      $('#moveLayer').transition {
        x : diffX + moveLayerX,
        y : diffY + moveLayerY
      }
      
      setMinimap {
        isTransition: true,
        mLx: diffX + moveLayerX,
        mLy: diffY + moveLayerY
      }
