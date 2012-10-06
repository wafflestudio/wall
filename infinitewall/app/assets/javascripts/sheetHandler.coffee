class window.SheetHandler
  sheet: null
  element: null

  deltax: 0
  deltay: 0
  startx: 0
  starty: 0
  startWidth: 0
  startHeight: 0
  hasMoved: false

  constructor: (sheet) ->
    @sheet = sheet
    @element = @sheet.element

    @element.on 'mousedown', '.boxClose', @onButtonMouseDown
    @element.on 'mousedown', '.resizeHandle', @onResizeMouseDown
    @element.on 'mousedown', @onMouseDown
    console.log(this)

  onMouseMove: (e) ->
    @element.css 'x', (@startx + e.pageX - @deltax) / glob.zoomLevel
    @element.css 'y', (@starty + e.pageY - @deltay) / glob.zoomLevel
    @hasMoved = true

    setMinimap()

  onMouseDown: (e) ->
    console.log(this)
    @hasMoved = false
    $('#moveLayer').append @element

    if glob.currentSheet
      glob.currentSheet.find('.boxClose').hide()
      glob.currentSheet.find('.sheetTextField').blur()
      $(glob.currentSheet.children('.sheet')).css 'border-top', ''
      $(glob.currentSheet.children('.sheet')).css 'margin-top', ''
      $('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'black'

    glob.currentSheet = @element
    glob.currentSheet.find('.boxClose').show()
    glob.currentSheet.children('.sheet').css 'border-top', '2px solid #FF4E58'
    glob.currentSheet.children('.sheet').css 'margin-top', '-2px'
    $('#map_' + glob.currentSheet.attr('id')).css 'background-color', 'crimson'

    startx = parseInt(@element.css('x')) * glob.zoomLevel
    starty = parseInt(@element.css('y')) * glob.zoomLevel

    deltax = e.pageX
    deltay = e.pageY

    $(document).on 'mousemove', @onMouseMove
    $(document).on 'mouseup', @onMouseUp
    e.stopPropagation()
    return false

  onButtonMouseDown: (e) ->
    $(document).on 'mouseup', @onButtonMouseUp
  
  onButtonMouseMove: (e) ->
    console.log e.pageX, e.pageY
  
  onButtonMouseUp: (e) ->
    element = @sheet.elemen
    $(document).off 'mousemove', @onMouseMove
    $(document).off 'mouseup', @onMouseUp
    element.trigger 'remove', {id : element.attr('id').substr(5)}
  
  onResizeMouseDown: (e) ->
    $(document).on 'mousemove', @onResizeMouseMove
    $(document).on 'mouseup', @onResizeMouseUp
    startWidth = parseInt(element.children('.sheet').css('width')) * glob.zoomLevel
    startHeight = parseInt(element.children('.sheet').css('height')) * glob.zoomLevel
    deltax = e.pageX
    deltay = e.pageY
    return false

  onResizeMouseMove: (e) ->
    element = @sheet.element
    element.children('.sheet').css 'width', (startWidth + e.pageX - deltax) / glob.zoomLevel
    element.children('.sheet').css 'height', (startHeight + e.pageY - deltay) / glob.zoomLevel

  onResizeMouseUp: (e) ->
    element = @sheet.element
    $(document).off 'mousemove', @onResizeMouseMove
    $(document).off 'mouseup', @onResizeMouseUp
    element.trigger 'resize', {
      id : element.attr('id').substr(5),
      width : (startWidth + e.pageX - deltax) / glob.zoomLevel,
      height : (startHeight + e.pageY - deltay) / glob.zoomLevel
    }
