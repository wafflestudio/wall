class ScaleLayer extends Movable
  constructor: () ->
    @element = $("#scaleLayer")
  
  setPoint: (tx, ty, x, y) ->
    @element.css {
      transformOrigin: tx + 'px ' + ty + 'px'
      x: x
      y: y
    }

  setZoom: (isTransition = false, callback) ->
    $('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
    if isTransition
      @element.transition {scale: glob.zoomLevel}, callback
    else
      @element.css {scale: glob.zoomLevel}

  set: (tx, ty, x, y, isTransition = false, callback) ->
    @setPoint(tx, ty, x, y)
    @setZoom(isTransition, callback)

class MoveLayer extends Movable
  constructor: () ->
    @element = $("#moveLayer")

class DockLayer extends Movable
  constructor: () ->
    @element = $("#dockLayer")

class window.Wall
  wall: null
  mL: null
  sL: null
  dL: null
  menu: null
  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  startlen: 0
  startzoom: 1
  xScaleLayer: 0
  yScaleLayer: 0
  xWallLast: 0
  yWallLast: 0
  hasMoved: false
  
  redrawInstantly: () =>
    @sL.redraw()
    @mL.redraw()
    for id, sheet of sheets
      sheet.redraw()
    console.log "redraw!"

  redraw: () ->
    if @redrawTimeout
      clearTimeout(@redrawTimeout)
    @redrawTimeout = setTimeout(@redrawInstantly, 400)

  save: () ->
    if @saveTimeout
      clearTimeout(@saveTimeout)

    @saveTimeout = setTimeout(
      () =>
        x = (glob.scaleLayerXPos + @mL.x() * glob.zoomLevel) / glob.zoomLevel
        y = (glob.scaleLayerYPos + @mL.y() * glob.zoomLevel) / glob.zoomLevel
        zoom = glob.zoomLevel
        console.log("x: #{x}, y: #{y}, zoom: #{zoom}")
        $.post("/wall/view/#{glob.wallId}", {x:x, y:y, zoom:zoom})
    ,1000)
  
  dock: (sheet) ->
    @dL.element.append sheet.element

  undock: (sheet) ->
    @bringToTop(sheet)

  bringToTop: (sheet) ->
    $("#sheetLayer").append sheet.element

  constructor: () ->
    @wall = $('#wall')
    @menu = $('#menuBar')
    @mL = new MoveLayer()
    @sL = new ScaleLayer()
    @dL = new DockLayer()
    @wall.on 'dblclick', @onMouseDblClick
    @wall.on 'mousedown', @onMouseDown
    @wall.on 'touchstart', @onTouchStart
    @wall.on 'mousewheel', @onMouseWheel
  
  onTouchStart: (e) =>
    len = e.originalEvent.touches.length
    @startx = @mL.x() * glob.zoomLevel
    @starty = @mL.y() * glob.zoomLevel
    
    if len is 1
      @hasMoved = false
      @deltax = e.originalEvent.pageX
      @deltay = e.originalEvent.pageY
      
      @onTouchEnd.xWall = e.originalEvent.pageX - @wall.offset().left
      @onTouchEnd.yWall = e.originalEvent.pageY - @wall.offset().top
    else # 첫번쨰 이후의 터치일 경우
      $(document).off 'touchmove', @onTouchMove
      $(document).off 'touchend', @onTouchEnd
      @deltax = e.originalEvent.pageX
      @deltay = e.originalEvent.pageY
      xlen = e.originalEvent.touches[0].pageX - e.originalEvent.touches[1].pageX
      ylen = e.originalEvent.touches[0].pageY - e.originalEvent.touches[1].pageY
      @startlen = Math.sqrt(xlen * xlen + ylen * ylen)
      @startzoom = glob.zoomLevel

    $(document).on 'touchmove', @onTouchMove
    $(document).on 'touchend', @onTouchEnd
    e.preventDefault()

  onTouchMove: (e) =>
    @hasMoved = true
    
    if e.originalEvent.touches.length is 1
      @mL.x((@startx + e.originalEvent.pageX - @deltax) / glob.zoomLevel)
      @mL.y((@starty + e.originalEvent.pageY - @deltay) / glob.zoomLevel)
    else # 터치가 2개 이상, pinch-to-zoom / 중점 기준으로 움직이게
      x = e.originalEvent.pageX
      y = e.originalEvent.pageY
      #그냥 이렇게 하면 따로 계산 안해도 중간 좌표값이 나오는듯
      
      xlen = e.originalEvent.touches[0].pageX - e.originalEvent.touches[1].pageX
      ylen = e.originalEvent.touches[0].pageY - e.originalEvent.touches[1].pageY
      
      xWall = x - @wall.offset().left
      yWall = y - @wall.offset().top
      
      #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

      @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
      @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
      
      #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
      #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
     
      glob.zoomLevel = @startzoom * Math.sqrt(xlen * xlen + ylen * ylen) / @startlen
      glob.zoomLevel = if glob.zoomLevel < 0.2 then 0.2 else (if glob.zoomLevel > 1 then 1 else glob.zoomLevel)
          
      xNew = (xWall - @xScaleLayer) / glob.zoomLevel
      yNew = (yWall - @yScaleLayer) / glob.zoomLevel

      #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
      
      @xWallLast = xWall
      @yWallLast = yWall

      glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
      glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel

      #scaleLayer의 좌표를 wall의 기준으로 저장
      @sL.set(@xScaleLayer, @yScaleLayer, xNew, yNew)
      #minimap.refresh()

  onTouchEnd: (e) =>
    $(document).off 'touchmove', @onTouchMove
    $(document).off 'touchend', @onTouchEnd
    
    if glob.activeSheet and not @hasMoved
      glob.activeSheet.resignActive()

    minimap.refresh()
    
    d = new Date()
    t = d.getTime()
    
    @onTouchEnd.lastTouch = @onTouchEnd.lastTouch || 0

    if t - @onTouchEnd.lastTouch < 300
      @xScaleLayer += (@onTouchEnd.xWall - @xWallLast) / glob.zoomLevel
      @yScaleLayer += (@onTouchEnd.yWall - @yWallLast) / glob.zoomLevel
      glob.zoomLevel = if glob.zoomLevel is 1 then 0.2 else 1
     
      if glob.zoomLevel is 1
        xNew = (@onTouchEnd.xWall - @xScaleLayer) / glob.zoomLevel
        yNew = (@onTouchEnd.yWall - @yScaleLayer) / glob.zoomLevel
      
      @xWallLast = @onTouchEnd.xWall
      @yWallLast = @onTouchEnd.yWall

      glob.scaleLayerXPos = @onTouchEnd.xWall - @xScaleLayer * glob.zoomLevel
      glob.scaleLayerYPos = @onTouchEnd.yWall - @yScaleLayer * glob.zoomLevel

      @sL.set(@onTouchEnd.xWall, @onTouchEnd.yWall, xNew, yNew, true)
      minimap.refresh {isTransition: true}
      @onTouchEnd.lastTouch = 0
     
    else
      @onTouchEnd.lastTouch = t

    @save()
    @redraw()

  onMouseMove: (e) =>
    @mL.x((@startx + e.pageX - @deltax) / glob.zoomLevel)
    @mL.y((@starty + e.pageY - @deltay) / glob.zoomLevel)
    @hasMoved = true
    minimap.refresh()

  onMouseUp: =>
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    @redraw()
    @save()

    if glob.activeSheet and not @hasMoved
      glob.activeSheet.resignActive()
  
  onMouseDown: (e) =>
    @hasMoved = false
    @startx = @mL.x() * glob.zoomLevel
    @starty = @mL.y() * glob.zoomLevel
    @deltax = e.pageX
    @deltay = e.pageY

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    e.preventDefault()
    
  onMouseWheel: (e, delta, deltaX, deltaY) =>

    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top

    #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

    @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
    @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
    
    #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
    #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
    
    delta /= 2.5
    tempDelta = if Math.abs(delta) < 0.15 then delta else (delta / Math.abs(delta)) * 0.15
    glob.zoomLevel += tempDelta
    glob.zoomLevel = if glob.zoomLevel < 0.2 then 0.2 else (if glob.zoomLevel > 1 then 1 else glob.zoomLevel)
        
    xNew = (xWall - @xScaleLayer) / glob.zoomLevel
    yNew = (yWall - @yScaleLayer) / glob.zoomLevel
    
    #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
    
    @xWallLast = xWall
    @yWallLast = yWall

    glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
    glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel

    #scaleLayer의 좌표를 wall의 기준으로 저장

    @sL.set(@xScaleLayer, @yScaleLayer, xNew, yNew)
    minimap.refresh()
    @redraw()
    @save()
    return false

  onMouseDblClick: (e) =>
    console.log "suspicious"
    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top

    @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
    @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
    
    glob.zoomLevel = if glob.zoomLevel is 1 then 0.2 else 1
   
    if glob.zoomLevel is 1
      xNew = (xWall - @xScaleLayer) / glob.zoomLevel
      yNew = (yWall - @yScaleLayer) / glob.zoomLevel
     
    @xWallLast = xWall
    @yWallLast = yWall

    glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
    glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel
    
    console.log "#{xWall}, #{yWall}, #{xNew}, #{yNew}"
    @sL.set(xWall, yWall, xNew, yNew, true)
    minimap.refresh {isTransition: true}

    @redraw()
    @save()
    return false

  revealSheet: ->

    #좌표는 moveLayer의 기준에서 본 wall의 좌표!
    screenWidth = ($(window).width() - 225) / glob.zoomLevel
    screenHeight = ($(window).height()) / glob.zoomLevel
    screenTop = -(glob.scaleLayerYPos + @mL.y() * glob.zoomLevel) / glob.zoomLevel
    screenLeft = -(glob.scaleLayerXPos + @mL.x() * glob.zoomLevel) / glob.zoomLevel

    sheet = glob.activeSheet
    sheetWidth = sheet.w()
    sheetHeight = sheet.h()
    sheetX = sheet.x()
    sheetY = sheet.y()

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
       
      mLX = @mL.x()
      mLY = @mL.y()
      
      @mL.tXY(diffX + mLX, diffY + mLY)
      
      minimap.refresh {
        isTransition: true,
        mLx: diffX + mLX,
        mLy: diffY + mLY
      }
      @redraw()
      @save()

  toCenter: (sheet, callback) ->
    sheetW = sheet.w()
    sheetH = sheet.h()
    screenW = $(window).width() - 225
    screenH = $(window).height()

    if glob.zoomLevel is 1
      mLX = @mL.x()
      mLY = @mL.y()
      
      screenT = -(glob.scaleLayerYPos + mLY * glob.zoomLevel) / glob.zoomLevel
      screenL = -(glob.scaleLayerXPos + mLX * glob.zoomLevel) / glob.zoomLevel
      
      sheetX = sheet.x()
      sheetY = sheet.y()

      translateX = screenL + (screenW - sheetW) / 2
      translateY = screenT + (screenH - sheetH) / 2

      diffX = translateX - sheetX
      diffY = translateY - sheetY
      
      @mL.tXY(diffX + mLX, diffY + mLY, callback)

      minimap.refresh {
        isTransition: true,
        mLx: diffX + mLX,
        mLy: diffY + mLY
      }

    else
      sheetX = (glob.scaleLayerXPos + (@mL.x() + sheet.x()) * glob.zoomLevel)
      sheetY = (glob.scaleLayerYPos + (@mL.y() + sheet.y()) * glob.zoomLevel)

      xWall = (sheetX - (screenW - sheetW) * (glob.zoomLevel / 2)) / (1 - glob.zoomLevel)
      yWall = (sheetY - (screenH - sheetH) * (glob.zoomLevel / 2)) / (1 - glob.zoomLevel)

      @xScaleLayer += (xWall - @xWallLast) / glob.zoomLevel
      @yScaleLayer += (yWall - @yWallLast) / glob.zoomLevel
      
      glob.zoomLevel = 1
      xNew = (xWall - @xScaleLayer) / glob.zoomLevel
      yNew = (yWall - @yScaleLayer) / glob.zoomLevel
      
      @xWallLast = xWall
      @yWallLast = yWall

      glob.scaleLayerXPos = xWall - @xScaleLayer * glob.zoomLevel
      glob.scaleLayerYPos = yWall - @yScaleLayer * glob.zoomLevel

      @sL.set(xWall, yWall, xNew, yNew, true, callback)
      minimap.refresh {isTransition: true}

    @save()
    @redraw()

  activateDelete: () ->
    $('#deleteSheetButton').css('background-image', 'url(/assets/images/delete_red.png)')
    
  deactivateDelete: () ->
    $('#deleteSheetButton').css('background-image', 'url(/assets/images/delete_white.png)')
