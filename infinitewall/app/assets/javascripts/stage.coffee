#variables

window.glob = new ->
  this.currentSheet = null
  this.zoomLevel = 1
  this.minimapToggled = 1
  this.rightBarOffset = 267 + 80 + 30 # 80은 위에 userList, 30은 밑에 input
  
  this.scaleLayerXPos = 0
  this.scaleLayerYPos = 0

  this.worldTop = 0
  this.worldBottom = 0
  this.worldLeft = 0
  this.worldRight = 0
  
  this.lastScrollTime = 0

window.contentTypeEnum = {
  text: "text",
  image: "image"
}
window.sheets = []


###
 
 
class TextSheetHandler extends SheetHandler
  constructor: (sheet) ->
    super(sheet)
    element = @sheet.element
    element.children('.sheet').on 'change', (e) ->
      element.trigger 'setText', e


class ImageSheetHandler extends SheetHandler
  imgWidth: null
  imgHeight: null

  constructor: (sheet) ->
    super(sheet)
    @imgWidth = parseInt(@sheet.element.css('width'))
    @imgHeight= parseInt(@sheet.element.css('height'))

  onResizeMouseMove: (e) ->
    element = @sheet.element
    dX = e.pageX - deltax
    dY = e.pageY - deltay
    ratio = imgWidth / imgHeight

    if Math.abs(dX / dY) > ratio
      element.children('.sheet').css 'width', (startWidth + dX) / glob.zoomLevel
      element.children('.sheet').css 'height', (startHeight + dX / ratio) / glob.zoomLevel
    else
      element.children('.sheet').css 'width', (startWidth + dY * ratio) / glob.zoomLevel
      element.children('.sheet').css 'height', (startHeight + dY) / glob.zoomLevel
###

#default functions for socket receive
createSheet = (id, params) ->
  if params.contentType == window.contentTypeEnum.text
    new TextSheet($.extend(params, {id : id}))
  else if params.contentType == window.contentTypeEnum.image
    new ImageSheet($.extend(params, {id : id}))

#handler
window.textSheetHandler = (elem) ->
  deltax = 0
  deltay = 0
  startx = 0
  starty = 0
  startWidth = 0
  startHeight = 0
  hasMoved = false
  element = $(elem)

  onMouseMove = (e) ->
    #if focus then no move
    if $("*:focus").is(".sheetTitle") or $("*:focus").is(".redactor_editor")
      return

    element.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
    element.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
    hasMoved = true
    setMinimap()
  
  onMouseUp = (e) ->
    $(document).off 'mousemove', onMouseMove
    $(document).off 'mouseup', onMouseUp

    if hasMoved
      element.trigger 'move', {
        id : element.attr('id').substr(5),
        x : (startx + e.pageX - deltax) / glob.zoomLevel,
        y : (starty + e.pageY - deltay) / glob.zoomLevel
      }
    else
      element.find('div.sheetTextField').trigger('activate')

  onMouseDown = (e) ->
    hasMoved = false
    $('#moveLayer').append element

    if glob.currentSheet
      glob.currentSheet.find('.boxClose').hide()
      glob.currentSheet.find('.sheetTextField').blur()
      glob.currentSheet.children('.sheet[contentType="image"]').children('.sheetTopBar').hide()
      $(glob.currentSheet.children('.sheet')).css 'border-top', ''
      $(glob.currentSheet.children('.sheet')).css 'margin-top', ''
      $('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'

    glob.currentSheet = element
    glob.currentSheet.find('.boxClose').show()
    glob.currentSheet.children('.sheet').css 'border-top', '2px solid #FF4E58'
    glob.currentSheet.children('.sheet').css 'margin-top', '-2px'

    miniElem = $('#map_' + glob.currentSheet.attr('id'))
    miniElem.css 'background-color', 'crimson'
    $('#minimapElements').append miniElem

    startx = parseInt(element.css('x')) * glob.zoomLevel
    starty = parseInt(element.css('y')) * glob.zoomLevel

    deltax = e.pageX
    deltay = e.pageY

    $(document).on 'mousemove', onMouseMove
    $(document).on 'mouseup', onMouseUp
    e.stopPropagation()

  onButtonMouseDown = (e) ->
    $(document).on 'mouseup', onButtonMouseUp
  
  onButtonMouseMove = (e) ->
    console.log e.pageX, e.pageY
  
  onButtonMouseUp = (e) ->
    $(document).off 'mousemove', onMouseMove
    $(document).off 'mouseup', onMouseUp
    element.trigger 'remove', {id : element.attr('id').substr(5)}
  
  onResizeMouseDown = (e) ->
    $(document).on 'mousemove', onResizeMouseMove
    $(document).on 'mouseup', onResizeMouseUp
    startWidth = parseInt(element.children('.sheet').css('width')) * glob.zoomLevel
    startHeight = parseInt(element.children('.sheet').css('height')) * glob.zoomLevel
    deltax = e.pageX
    deltay = e.pageY
    return false

  onResizeMouseMove = (e) ->
    element.children('.sheet').css 'width', (startWidth + e.pageX - deltax) / glob.zoomLevel
    element.children('.sheet').css 'height', (startHeight + e.pageY - deltay) / glob.zoomLevel

  onResizeMouseUp = (e) ->
    $(document).off 'mousemove', onResizeMouseMove
    $(document).off 'mouseup', onResizeMouseUp
    element.trigger 'resize', {
      id : element.attr('id').substr(5),
      width : (startWidth + e.pageX - deltax) / glob.zoomLevel,
      height : (startHeight + e.pageY - deltay) / glob.zoomLevel
    }

  element.on 'mousedown', '.boxClose', onButtonMouseDown
  element.on 'mousedown', '.resizeHandle', onResizeMouseDown
  element.on 'mousedown', onMouseDown
  
  element.children('.sheet').on 'change', (e) ->
    element.trigger 'setText', e


window.imageSheetHandler = (elem) ->
  element = $(elem)
  deltax = 0
  deltay = 0
  startx = 0
  starty = 0
  startWidth = 0
  startHeight = 0
  imgWidth = parseInt(element.css('width'))
  imgHeight= parseInt(element.css('height'))
  hasMoved = false

  onMouseMove = (e) ->
    element.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
    element.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
    hasMoved = true
    setMinimap()
  
  onMouseUp = (e) ->
    $(document).off 'mousemove', onMouseMove
    $(document).off 'mouseup', onMouseUp

    if hasMoved
      element.trigger 'move', {
        id : element.attr('id').substr(5),
        x : (startx + e.pageX - deltax) / glob.zoomLevel,
        y : (starty + e.pageY - deltay) / glob.zoomLevel
      }

  onMouseDown = (e) ->
    hasMoved = false
    $('#moveLayer').append element

    if glob.currentSheet
      glob.currentSheet.find('.boxClose').hide()
      glob.currentSheet.children('.sheet[contentType="image"]').children('.sheetTopBar').hide()
      #glob.currentSheet.find('.sheetTextField').blur()
      $(glob.currentSheet.children('.sheet')).css 'border-top', ''
      $(glob.currentSheet.children('.sheet')).css 'margin-top', ''
      $('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'

    glob.currentSheet = element
    glob.currentSheet.find('.boxClose').show()
    glob.currentSheet.children('.sheet').css 'border-top', '2px solid #FF4E58'
    glob.currentSheet.children('.sheet').css 'margin-top', '-2px'
    glob.currentSheet.find('.sheetTopBar').show()
    
    miniElem = $('#map_' + glob.currentSheet.attr('id'))
    miniElem.css 'background-color', 'crimson'
    $('#minimapElements').append miniElem

    startx = parseInt(element.css('x')) * glob.zoomLevel
    starty = parseInt(element.css('y')) * glob.zoomLevel

    deltax = e.pageX
    deltay = e.pageY

    $(document).on 'mousemove', onMouseMove
    $(document).on 'mouseup', onMouseUp
    e.stopPropagation()

  onButtonMouseDown = (e) ->
    $(document).on 'mouseup', onButtonMouseUp
  
  onButtonMouseMove = (e) ->
    console.log e.pageX, e.pageY
  
  onButtonMouseUp = (e) ->
    $(document).off 'mousemove', onMouseMove
    $(document).off 'mouseup', onMouseUp
    element.trigger 'remove', 
    #여기는 이렇게 콤마 뒤에 암것도 안놔둬도 괜찮은건가 뭔가 작업하다가 사라진걸까

  onResizeMouseDown = (e) ->
    $(document).on 'mousemove', onResizeMouseMove
    $(document).on 'mouseup', onResizeMouseUp
    startWidth = parseInt(element.children('.sheet').css('width')) * glob.zoomLevel
    startHeight = parseInt(element.children('.sheet').css('height')) * glob.zoomLevel
    deltax = e.pageX
    deltay = e.pageY
    return false

  onResizeMouseMove = (e) ->
    dX = e.pageX - deltax
    dY = e.pageY - deltay
    ratio = imgWidth / imgHeight

    if Math.abs(dX / dY) > ratio
      element.children('.sheet').css 'width', (startWidth + dX) / glob.zoomLevel
      element.children('.sheet').css 'height', (startHeight + dX / ratio) / glob.zoomLevel
    else
      element.children('.sheet').css 'width', (startWidth + dY * ratio) / glob.zoomLevel
      element.children('.sheet').css 'height', (startHeight + dY) / glob.zoomLevel


  onResizeMouseUp = (e) ->
    $(document).off 'mousemove', onResizeMouseMove
    $(document).off 'mouseup', onResizeMouseUp
    element.trigger 'resize', 
      id: element.attr('id').substr(5),
      width: parseInt(element.children('.sheet').css('width')),
      height: parseInt(element.children('.sheet').css('height'))
  
  element.on 'mousedown', '.boxClose', onButtonMouseDown
  element.on 'mousedown', '.resizeHandle', onResizeMouseDown
  element.on 'mousedown', onMouseDown




wallHandler = (element) ->
  deltax = 0
  deltay = 0
  startx = 0
  starty = 0
  mL = $('#moveLayer')
  xScaleLayer = 0
  yScaleLayer = 0
  xWallLast = 0
  yWallLast = 0
  hasMoved = false

  onMouseMove = (e) ->
    mL.css 'x', (startx + e.pageX - deltax) / glob.zoomLevel
    mL.css 'y', (starty + e.pageY - deltay) / glob.zoomLevel
    setMinimap()
    hasMoved = true
  
  onMouseUp = ->
    $(document).off 'mousemove', onMouseMove
    $(document).off 'mouseup', onMouseUp
    if glob.currentSheet and not hasMoved
      glob.currentSheet.find('.boxClose').hide()
      glob.currentSheet.find('.sheetTextField').blur()
      glob.currentSheet.children('.sheet').css 'border-top', ''
      glob.currentSheet.children('.sheet').css 'margin-top', ''
      glob.currentSheet.children('.sheet[contentType="image"]').children('.sheetTopBar').hide()
      $('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'
  
  onMouseDown = (e) ->
    hasMoved = false
    startx = parseInt((mL.css 'x')) * glob.zoomLevel
    starty = parseInt((mL.css 'y')) * glob.zoomLevel
    deltax = e.pageX
    deltay = e.pageY

    $(document).on 'mousemove', onMouseMove
    $(document).on 'mouseup', onMouseUp
    e.preventDefault()

  onMouseWheel = (e, delta, deltaX, deltaY) ->

    stopScroll = false

    xWall = e.pageX - $(this).offset().left
    yWall = e.pageY - $(this).offset().top - 38

    #-38은 #wall이 위에 네비게이션 바 밑으로 들어간 38픽셀에 대한 compensation
    #xWall, yWall은 wall의 (0,0)을 origin으로 본 마우스 커서 위치

    xScaleLayer += (xWall - xWallLast) / glob.zoomLevel
    yScaleLayer += (yWall - yWallLast) / glob.zoomLevel
    
    #xWall - xWallLast는 저번과 현재의 마우스 좌표 차이 
    #xScaleLayer, yScaleLayer는 scaleLayer의 (0,0)을 origin 으로 본 마우스의 좌표이며, 이는 transformOrigin의 좌표가 됨
    

    glob.zoomLevel += delta / 2.5


    glob.zoomLevel = if glob.zoomLevel < 0.25 then 0.25 else (if glob.zoomLevel > 1 then 1 else glob.zoomLevel)
        

    xNew = (xWall - xScaleLayer) / glob.zoomLevel
    yNew = (yWall - yScaleLayer) / glob.zoomLevel
    
    #xNew, yNew는 wall기준 mouse위치와 scaleLayer기준 mouseLayer 의 차..
    
    xWallLast = xWall
    yWallLast = yWall

    glob.scaleLayerXPos = xWall - xScaleLayer * glob.zoomLevel
    glob.scaleLayerYPos = yWall - yScaleLayer * glob.zoomLevel

    #scaleLayer의 좌표를 wall의 기준으로 저장

    sL = $('#scaleLayer')
    sL.css {scale : glob.zoomLevel}

    #This tweak makes the scaling a bit smoother - at the expense of crispness
    #sL.css {transform :"scale3d(#{glob.zoomLevel}, #{glob.zoomLevel}, 1)"}

    sL.css 'x', xNew
    sL.css 'y', yNew
    sL.css({transformOrigin:xScaleLayer + 'px ' + yScaleLayer + 'px'})
    $('.boxClose').css {scale : 1 / glob.zoomLevel}
    $('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
    setMinimap()
    return false

  $(element).on 'mousedown', onMouseDown
  $(element).on 'mousewheel', onMouseWheel
  


toggleMinimap = ->
  if glob.minimapToggled
    glob.minimapToggled = 0
    $('#miniMap').animate {right: '-220'}, 200, toggleMinimapFinished
  else
    glob.minimapToggled = 1
    $('#chatWindow').animate {height: '-=190'}, 200, toggleMinimapFinished

toggleMinimapFinished = ->
  if glob.minimapToggled
    $('#miniMap').animate {right: '0'}, 200
    glob.rightBarOffset += 190
  else
    $('#chatWindow').animate {height: '+=190'}, 200
    glob.rightBarOffset -= 190

setMinimap = ->
  
  #좌표는 moveLayer의 기준에서 본 wall의 좌표!
  sB = $('.sheetBox')
  screenWidth = ($(window).width() - 225) / glob.zoomLevel
  screenHeight = ($(window).height() - 74) / glob.zoomLevel
  screenTop = -(glob.scaleLayerYPos + (parseInt ($('#moveLayer').css 'y')) * glob.zoomLevel) / glob.zoomLevel
  screenBottom = screenTop + screenHeight
  screenLeft = -(glob.scaleLayerXPos + (parseInt ($('#moveLayer').css 'x')) * glob.zoomLevel) / glob.zoomLevel
  screenRight = screenLeft + screenWidth

  glob.worldTop = screenTop
  glob.worldBottom = screenBottom
  glob.worldLeft = screenLeft
  glob.worldRight = screenRight

  updateWorldSize = (elem) ->
    elemX = parseInt (elem.css('x'))
    elemY = parseInt (elem.css('y'))
    elemWidth = parseInt (elem.css('width'))
    elemHeight = parseInt (elem.css('height'))

    glob.worldLeft = elemX if elemX < glob.worldLeft
    glob.worldRight = elemX + elemWidth if elemX + elemWidth > glob.worldRight
    glob.worldTop = elemY if elemY < glob.worldTop
    glob.worldBottom = elemY + elemHeight if elemY + elemHeight > glob.worldBottom
  
  updateWorldSize $(elem) for elem in sB

  worldWidth = glob.worldRight - glob.worldLeft
  worldHeight = glob.worldBottom - glob.worldTop
  ratio = 1
  mE = $('#minimapElements')
  mCS = $('#minimapCurrentScreen')

  if (worldWidth / worldHeight) > (224 / 185)
    ratio = 224 / worldWidth
    mE.css 'width', 224
    mE.css 'height', worldHeight * ratio
    mE.css 'top', (185 - worldHeight * ratio) / 2
    mE.css 'left', 0
  
  else
    ratio = 185 / worldHeight
    mE.css 'width', worldWidth * ratio
    mE.css 'height', 185
    mE.css 'top', 0
    mE.css 'left', (224 - worldWidth * ratio) / 2
  
  mCS.css 'width', screenWidth * ratio
  mCS.css 'height', screenHeight * ratio
  mCS.css 'top', (screenTop - glob.worldTop) * ratio
  mCS.css 'left', (screenLeft - glob.worldLeft) * ratio
  
  shrinkMiniSheet = (elem) ->
    miniSheet = $('#map_' + elem.attr('id'))
    miniSheet.css 'left', ((parseInt elem.css('x')) - glob.worldLeft) * ratio
    miniSheet.css 'top', ((parseInt elem.css('y')) - glob.worldTop) * ratio
    miniSheet.css 'width', ((parseInt elem.css('width'))) * ratio
    miniSheet.css 'height', ((parseInt elem.css('height'))) * ratio
  
  shrinkMiniSheet $(elem) for elem in sB

window.createSheet = createSheet
window.setMinimap = setMinimap


$(window).resize ->
  $('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  setMinimap()

$ () ->
  wallHandler('#wall')
  
  $('#fileupload').fileupload  {
    dataType : 'json',
    done : (e, data) ->
      $.each(data.result, (index, file) ->
        ImageSheet.create("/assets/files/#{file.name}")
      )
  }

  $('.createBtn').live('click', () ->
    if $(this).attr('rel') == 'text'
      TextSheet.create("text")
  )

  $('#minimapBtn').click toggleMinimap
  $('#chatWindow').height ($(window).height() - glob.rightBarOffset)
  $('#zoomLevelText').text ("#{parseInt(glob.zoomLevel * 100)}%")
  $('#currentWallNameText').text "First wall"

