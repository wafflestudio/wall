class window.MiniSheet
  id: null
  element: null

  constructor: (id) ->
    @id = id
    @element = $($('<div class = "minimapElement"></div>').appendTo('#minimapElements'))
    @element.attr('id', 'map_sheet' + id)
    @element.on 'mousedown', @onMouseDown
    
  becomeActive: () ->
    @element.css 'background-color', 'crimson'

  resignActive: () ->
    @element.css 'background-color', 'black'

  becomeSelected: () ->
    @element.css 'background-color', '#96A6D6'

  remove: () ->
    @element.remove()
    #delete miniSheets[@id]

  getXY: () ->
    x: parseInt(@element.css('x'))
    y: parseInt(@element.css('y'))

  setXY: (x, y, moveFunc = $.fn.css, duration) ->
    @element.moveFunc {
      x: x,
      y: y
    }, duration

  getWH: () ->
    w: parseInt(@element.css('width'))
    h: parseInt(@element.css('height'))

  setWH: (w, h, moveFunc = $.fn.css, duration) ->
    @element.moveFunc {
      width: w,
      height: h
    }, duration

  onMouseDown: (e) =>

    #xWall = e.pageX - $(this).offset().left
    #yWall = e.pageY - $(this).offset().top - 38

    #xScaleLayer += (xWall - xWallLast) / glob.zoomLevel
    #yScaleLayer += (yWall - yWallLast) / glob.zoomLevel
    
    #glob.zoomLevel = if glob.zoomLevel is 1 then 0.25 else 1
   
    #if glob.zoomLevel is 1
      #xNew = (xWall - xScaleLayer) / glob.zoomLevel
      #yNew = (yWall - yScaleLayer) / glob.zoomLevel
    
    #xWallLast = xWall
    #yWallLast = yWall

    #glob.scaleLayerXPos = xWall - xScaleLayer * glob.zoomLevel
    #glob.scaleLayerYPos = yWall - yScaleLayer * glob.zoomLevel
    
    #glob.zoomLevel = 1

    #sL = $('#scaleLayer')
    #sL.css {transformOrigin: xWall + 'px ' + yWall + 'px'}
    #sL.transition {scale: glob.zoomLevel}
    #sL.css 'x', xNew
    #sL.css 'y', yNew
    #$('.boxClose').transition {scale: 1 / glob.zoomLevel}
    #$('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
    
    # 화면이 100%로 확대되게 만들어야
    @becomeSelected()
    sheet = sheets[@id]
    
    screenW = ($(window).width() - 225) / glob.zoomLevel
    screenH = ($(window).height() - 38) / glob.zoomLevel
    screenT = -(glob.scaleLayerYPos + wall.getMLxy().y * glob.zoomLevel) / glob.zoomLevel
    screenL = -(glob.scaleLayerXPos + wall.getMLxy().x * glob.zoomLevel) / glob.zoomLevel

    #screenW = wall.screenWidth()
    #screenH = wall.screenHeight()
    #screenT = wall.screenTop()
    #screenL = wall.screenLeft()

    sheetW = sheet.getWH().w
    sheetH = sheet.getWH().h
    sheetX = sheet.getXY().x
    sheetY = sheet.getXY().y

    translateX = screenL + (screenW - sheetW) / 2
    translateY = screenT + (screenH - sheetH) / 2

    diffX = translateX - sheetX
    diffY = translateY - sheetY

    moveLayerX = wall.getMLxy().x
    moveLayerY = wall.getMLxy().y
    
    wall.mL.transition {
      x : diffX + moveLayerX,
      y : diffY + moveLayerY
    }, () =>
      if glob.activeSheet is sheets[@id]
        @becomeActive()
      else
        @resignActive()
    
    minimap.refresh {
      isTransition: true,
      mLx: diffX + moveLayerX,
      mLy: diffY + moveLayerY
    }

    return false
