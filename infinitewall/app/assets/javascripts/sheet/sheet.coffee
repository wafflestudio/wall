class window.Sheet
  id: null
  element: null
  handler: null

  @create: (content) ->
    #interface for random creation

  setElement: () ->
    #interface for element creation

  constructor: (params) ->
    self = this

    @id = params.id
    @setElement()

    prevTitle = params.title

    @element.attr 'id', 'sheet' + params.id

    @setXY(params.x, params.y)
    @setWH(params.width, params.height)

    @element.children('.boxClose').css {scale: 1 / glob.zoomLevel}

    @element.find('.sheetTitle').keydown (e) ->
      curTitle = self.element.find('.sheetTitle').html()
      if e.keyCode is 13
        curTitle = msg.substr(0, msg.length - 1) if curTitle.charAt(curTitle.length - 1) is '\n'
        if prevTitle isnt curTitle
          self.element.trigger 'setTitle'
          prevTitle = curTitle
          self.element.find('.sheetTitle').blur()
          return false
    .focusout (e) ->
      curTitle = self.element.find('.sheetTitle').html()
      $(self.element).trigger ('setTitle') if prevTitle isnt curTitle
      prevTitle = curTitle
    .html(params.title)
   
    @attachHandler()

    newMiniSheet = new MiniSheet(@id)
    window.miniSheets[@id] = newMiniSheet
    window.sheets[params.id] = this
    minimap.refresh()
    

  socketMove: (params) ->
    wallSocket.send {action : 'move', params : $.extend(params, {id : @id})}

  socketResize: (params) ->
    wallSocket.send {action : 'resize', params : $.extend(params, {id : @id})}

  socketRemove: () ->
    wallSocket.send {action : 'remove', params : {id : @id}}

  socketSetTitle: () ->
    wallSocket.send {action : 'setTitle', params : {id : @id, title : @element.find('.sheetTitle').html()}}

  attachHandler: () ->

  move: (params) ->
    @element.transition {x : params.x, y : params.y}

  resize: (params) ->
    @element.children('.sheet').transition {width : params.width + "px", height : params.height + "px"}

  remove: (params) ->
    @element.transition {opacity: 0, scale : 1.25}, -> $(this).remove()
    @element.off 'mousemove'
    @element.off 'mouseup'
    @element.off 'mousedown'
    $('#map_sheet' + params.id).remove()

  setTitle: (params) ->
    @element.find('.sheetTitle').html(params.title)

  becomeActive: () ->
    glob.activeSheet = this
    @element.find('.boxClose').show()
    @element.children('.sheet').css 'border-top', '2px solid #FF4E58'
    @element.children('.sheet').css 'margin-top', '-2px'
    @element.find('.sheetTopBar').show()

  resignActive: () ->
    @element.find('.boxClose').hide()
    @element.find('.sheetTextField').blur()
    @element.children('.sheet[contentType="image"]').children('.sheetTopBar').hide()
    @element.children('.sheet').css 'border-top', ''
    @element.children('.sheet').css 'margin-top', ''
    $('#map_' + @element.attr('id')).css 'background-color', 'black'

  setXY: (x, y) ->
    @element.css({x: x, y: y})

  getXY: () ->
    x: parseInt(@element.css('x'))
    y: parseInt(@element.css('y'))

  setWH: (w, h) ->
    @element.children('.sheet').css({width: w, height: h})

  getWH: () ->
    w: parseInt(@element.children('.sheet').css('width'))
    h: parseInt(@element.children('.sheet').css('height'))
