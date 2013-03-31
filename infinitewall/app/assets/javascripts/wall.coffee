class ScaleLayer extends Movable
  constructor: ->
    super(false)
    @element = $("#scaleLayer")
  
  setPoint: (tx, ty, x, y) ->
    @element.css {
      transformOrigin: parseInt(tx) + 'px ' + parseInt(ty) + 'px'
      x: parseInt(x)
      y: parseInt(y)
    }

  setZoomText: (percentage) ->
    $('#zoomText').text ("#{percentage}%")

  setZoom: (isTransition = false, callback) ->
    if isTransition
      $("#zoomBar").width(@element.css("scale") * 100)
      $("#zoomBar").animate {width: stage.zoom * 100}, {step: (now) => @setZoomText(Math.round(now))}
      # transform3d의 scale값을 매번 가져올 수 없기때문에 쓰는 꼼수..
      # jquery.transit에서 step function을 받는 패치가 나오면 고쳐도 될듯

      @element.transition {scale: stage.zoom}, callback
    else
      @element.css {scale: stage.zoom}
      @setZoomText(parseInt(stage.zoom * 100))

  set: (tx, ty, x, y, isTransition = false, callback) ->
    @setPoint(tx, ty, x, y)
    @setZoom(isTransition, callback)

class MoveLayer extends Movable
  constructor: ->
    super(false)
    @element = $("#moveLayer")

  stopTransitioning: ->
    @element.clearQueue()

class DockLayer extends Movable
  constructor: ->
    super(false)
    @element = $("#dockLayer")

class DeleteLayer extends Movable
  constructor: ->
    super(false)
    @element = $("#removeLayer")
    @element.on 'proximity', {max : 100}, (e, proximity, distance) ->
      return unless stage.draggingSheet?

      if proximity is 1
        $(@).addClass("activatedRemove")
      else
        $(@).removeClass("activatedRemove")
        $(@).css { opacity: 0.3 + proximity * 0.7 }
  
  reset: ->
    @element.removeClass("activatedRemove")
    @element.css {opacity: 0.3}

class window.Wall
  wall: null
  mL: null
  sL: null
  dL: null
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
  
  save: ->
    clearTimeout(@saveTimeout) if @saveTimeout
    @saveTimeout = setTimeout(
      () =>
        x = (stage.scaleLayerX + @mL.x * stage.zoom) / stage.zoom
        y = (stage.scaleLayerY + @mL.y * stage.zoom) / stage.zoom
        zoom = stage.zoom
        console.log("x: #{x}, y: #{y}, zoom: #{zoom}")
        $.post("/wall/view/#{stage.wallId}", {x:x, y:y, zoom:zoom})
    ,1000)
  
  dock: (sheet) -> @dL.element.append sheet.element
  undock: (sheet) -> @bringToTop(sheet)

  bringToTop: (sheet) ->
    #sheet.element.css("z-index", stage.zCount++)
    #setTimeout(
      #() ->
        #$("#sheetLayer").append sheet.element
        #sheet.element.css("z-index", "")
        #stage.zCount = 1
      #, 500)
  
  loadPref: (zoom, panX, panY) ->
    stage.zoom = zoom
    @sL.setZoom()
    @mL.x = panX
    @mL.y = panY
    minimap.refresh()

  constructor: ->
    @wall = $('#wall')
    @mL = new MoveLayer()
    @sL = new ScaleLayer()
    @dL = new DockLayer()
    @removeLayer = new DeleteLayer()
    @wall.on 'dblclick', @onMouseDblClick
    @wall.on 'mousedown', @onMouseDown
    @wall.on 'touchstart', @onTouchStart
    @wall.on 'mousewheel', @onMouseWheel

  onTouchStart: (e) =>
    console.log e
    len = e.originalEvent.touches.length
    @startx = @mL.x * stage.zoom
    @starty = @mL.y * stage.zoom
    
    if len is 1
      @hasMoved = false
      @deltax = e.originalEvent.touches[0].pageX
      @deltay = e.originalEvent.touches[0].pageY

      @onTouchEnd.xWall = @deltax - @wall.offset().left
      @onTouchEnd.yWall = @deltay - @wall.offset().top
    else # 첫번쨰 이후의 터치일 경우
      $(document).off 'touchmove', @onTouchMove
      $(document).off 'touchend', @onTouchEnd
      @deltax = (e.originalEvent.touches[0].pageX + e.originalEvent.touches[1].pageX) / 2
      @deltay = (e.originalEvent.touches[0].pageY + e.originalEvent.touches[1].pageY) / 2
      xlen = e.originalEvent.touches[0].pageX - e.originalEvent.touches[1].pageX
      ylen = e.originalEvent.touches[0].pageY - e.originalEvent.touches[1].pageY
      @startlen = Math.sqrt(xlen * xlen + ylen * ylen)
      @startzoom = stage.zoom

    $(document).on 'touchmove', @onTouchMove
    $(document).on 'touchend', @onTouchEnd
    e.preventDefault()

  onTouchMove: (e) =>
    @hasMoved = true
    
    if e.originalEvent.touches.length is 1
      @mL.x = (@startx + e.originalEvent.touches[0].pageX - @deltax) / stage.zoom
      @mL.y = (@starty + e.originalEvent.touches[0].pageY - @deltay) / stage.zoom
    else # 터치가 2개 이상, pinch-to-zoom / 중점 기준으로 움직이게
      x = e.originalEvent.touches[0].pageX
      y = e.originalEvent.touches[0].pageY
      #x = e.originalEvent.pageX
      #y = e.originalEvent.pageY
      #중간 값 찾는 알고리즘 써야
      
      xlen = e.originalEvent.touches[0].pageX - e.originalEvent.touches[1].pageX
      ylen = e.originalEvent.touches[0].pageY - e.originalEvent.touches[1].pageY
      
      xWall = x - @wall.offset().left
      yWall = y - @wall.offset().top
      
      #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

      @xScaleLayer += (xWall - @xWallLast) / stage.zoom
      @yScaleLayer += (yWall - @yWallLast) / stage.zoom
      
      #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
      #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
     
      stage.zoom = @startzoom * Math.sqrt(xlen * xlen + ylen * ylen) / @startlen
      stage.zoom = if stage.zoom < 0.2 then 0.2 else (if stage.zoom > 1 then 1 else stage.zoom)
          
      xNew = (xWall - @xScaleLayer) / stage.zoom
      yNew = (yWall - @yScaleLayer) / stage.zoom

      #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
      
      @xWallLast = xWall
      @yWallLast = yWall

      stage.scaleLayerX = xWall - @xScaleLayer * stage.zoom
      stage.scaleLayerY = yWall - @yScaleLayer * stage.zoom

      #scaleLayer의 좌표를 wall의 기준으로 저장
      @sL.set(@xScaleLayer, @yScaleLayer, xNew, yNew)
      #minimap.refresh()

  onTouchEnd: (e) =>
    $(document).off 'touchmove', @onTouchMove
    $(document).off 'touchend', @onTouchEnd
    
    if stage.activeSheet and not @hasMoved
      stage.activeSheet.resignActive()

    minimap.refresh()
    
    d = new Date()
    t = d.getTime()
    
    @onTouchEnd.lastTouch = @onTouchEnd.lastTouch || 0

    if t - @onTouchEnd.lastTouch < 300
      @xScaleLayer += (@onTouchEnd.xWall - @xWallLast) / stage.zoom
      @yScaleLayer += (@onTouchEnd.yWall - @yWallLast) / stage.zoom
      stage.zoom = if stage.zoom is 1 then 0.2 else 1
     
      if stage.zoom is 1
        xNew = (@onTouchEnd.xWall - @xScaleLayer) / stage.zoom
        yNew = (@onTouchEnd.yWall - @yScaleLayer) / stage.zoom
      
      @xWallLast = @onTouchEnd.xWall
      @yWallLast = @onTouchEnd.yWall

      stage.scaleLayerX = @onTouchEnd.xWall - @xScaleLayer * stage.zoom
      stage.scaleLayerY = @onTouchEnd.yWall - @yScaleLayer * stage.zoom

      @sL.set(@onTouchEnd.xWall, @onTouchEnd.yWall, xNew, yNew, true)
      minimap.refresh {isTransition: true}
      @onTouchEnd.lastTouch = 0
     
    else
      @onTouchEnd.lastTouch = t

    @save()

  onMouseMove: (e) =>
    @mL.x = (@startx + e.pageX - @deltax) / stage.zoom
    @mL.y = (@starty + e.pageY - @deltay) / stage.zoom
    @hasMoved = true
    minimap.refresh()

  onMouseUp: =>
    stage.leftClick = false
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    @save()

    if stage.activeSheet and not @hasMoved
      stage.activeSheet.resignActive()
  
  onMouseDown: (e) =>
    console.log e.pageX, e.pageY
    stage.leftClick = true
    @hasMoved = false
    @startx = @mL.x * stage.zoom
    @starty = @mL.y * stage.zoom
    @deltax = e.pageX
    @deltay = e.pageY

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    e.preventDefault()
    
  onMouseWheel: (e, delta, deltaX, deltaY) =>
    return if stage.leftClick
    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top

    #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

    @xScaleLayer += (xWall - @xWallLast) / stage.zoom
    @yScaleLayer += (yWall - @yWallLast) / stage.zoom
    
    #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
    #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
    
    delta /= 2.5
    tempDelta = if Math.abs(delta) < 0.15 then delta else (delta / Math.abs(delta)) * 0.15
    stage.zoom += tempDelta
    stage.zoom = if stage.zoom < 0.2 then 0.2 else (if stage.zoom > 1 then 1 else Math.round(stage.zoom * 100) / 100)
        
    xNew = (xWall - @xScaleLayer) / stage.zoom
    yNew = (yWall - @yScaleLayer) / stage.zoom
    
    #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
    
    @xWallLast = xWall
    @yWallLast = yWall

    stage.scaleLayerX = xWall - @xScaleLayer * stage.zoom
    stage.scaleLayerY = yWall - @yScaleLayer * stage.zoom

    #scaleLayer의 좌표를 wall의 기준으로 저장

    @sL.set(@xScaleLayer, @yScaleLayer, xNew, yNew)
    minimap.refresh()
    @save()
    return false

  onMouseDblClick: (e) =>
    return false unless e.eventPhase is 2
    # 월을 바로 눌렀을때만 되고 bubbling해서 올라오는건 못하게

    xWall = e.pageX - @wall.offset().left
    yWall = e.pageY - @wall.offset().top

    @xScaleLayer += (xWall - @xWallLast) / stage.zoom
    @yScaleLayer += (yWall - @yWallLast) / stage.zoom
    
    stage.zoom = if stage.zoom is 1 then 0.2 else 1
   
    if stage.zoom is 1
      xNew = (xWall - @xScaleLayer) / stage.zoom
      yNew = (yWall - @yScaleLayer) / stage.zoom
     
    @xWallLast = xWall
    @yWallLast = yWall

    stage.scaleLayerX = xWall - @xScaleLayer * stage.zoom
    stage.scaleLayerY = yWall - @yScaleLayer * stage.zoom
    
    @sL.set(xWall, yWall, xNew, yNew, true)
    minimap.refresh {isTransition: true}

    @save()
    return false

  revealSheet: ->

    #좌표는 moveLayer의 기준에서 본 wall의 좌표!
    screenWidth = ($(window).width() - 70) / stage.zoom
    screenHeight = ($(window).height()) / stage.zoom
    screenTop = -(stage.scaleLayerY + @mL.y * stage.zoom) / stage.zoom
    screenLeft = -(stage.scaleLayerX - 70 + @mL.x * stage.zoom) / stage.zoom

    sheet = stage.activeSheet
    sheetWidth = sheet.w
    sheetHeight = sheet.h
    sheetX = sheet.x
    sheetY = sheet.y

    return if sheetWidth > screenWidth or sheetHeight > screenHeight
    
    #일단은 이렇게 해둠..

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
       
      @mL.txy(diffX + @mL.x, diffY + @mL.y)

      minimap.refresh {
        isTransition: true
        mLx: diffX + @mL.x
        mLy: diffY + @mL.y
      }

      @save()

  center: (info, callback) ->
    if info instanceof Sheet
      x = info.x
      y = info.y
      w = info.w
      h = info.h
    else
      x = info.x
      y = info.y
      w = h = 0

    screenW = $(window).width() - 70
    screenH = $(window).height()

    if stage.zoom is 1
      mLX = @mL.x
      mLY = @mL.y
      
      screenT = -(stage.scaleLayerY + mLY * stage.zoom) / stage.zoom
      screenL = -(stage.scaleLayerX + mLX * stage.zoom) / stage.zoom
      
      translateX = screenL + (screenW - w) / 2
      translateY = screenT + (screenH - h) / 2

      diffX = translateX - x
      diffY = translateY - y
      
      @mL.txy(diffX + mLX, diffY + mLY, callback)

      minimap.refresh {
        isTransition: true,
        mLx: diffX + mLX,
        mLy: diffY + mLY
      }

    else
      sheetX = (stage.scaleLayerX + (@mL.x + x) * stage.zoom)
      sheetY = (stage.scaleLayerY + (@mL.y + y) * stage.zoom)

      xWall = (sheetX - (screenW - w) * (stage.zoom / 2)) / (1 - stage.zoom)
      yWall = (sheetY - (screenH - h) * (stage.zoom / 2)) / (1 - stage.zoom)

      @xScaleLayer += (xWall - @xWallLast) / stage.zoom
      @yScaleLayer += (yWall - @yWallLast) / stage.zoom
      
      stage.zoom = 1
      xNew = (xWall - @xScaleLayer) / stage.zoom
      yNew = (yWall - @yScaleLayer) / stage.zoom
      
      @xWallLast = xWall
      @yWallLast = yWall

      stage.scaleLayerX = xWall - @xScaleLayer * stage.zoom
      stage.scaleLayerY = yWall - @yScaleLayer * stage.zoom

      @sL.set(xWall, yWall, xNew, yNew, true, callback)
      minimap.refresh {isTransition: true}

    @save()
