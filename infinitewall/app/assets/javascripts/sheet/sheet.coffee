class window.Sheet extends Movable
  links: null
  docked: false

  @create: (content) ->
    #interface for random creation

  setElement: (params) ->

  constructor: (params) ->
    @id = params.id
    @setElement()
    @x(params.x)
    @y(params.y)
    @iw(params.width)
    @ih(params.height)

    @element.attr 'id', 'sheet' + params.id
    @links = new Object()
    
    prevTitle = params.title

    @element.find('.sheetTitle').keydown (e) =>
      curTitle = @element.find('.sheetTitle').html()
      if e.keyCode is 13
        curTitle = msg.substr(0, msg.length - 1) if curTitle.charAt(curTitle.length - 1) is '\n'
        if prevTitle isnt curTitle
          @socketSetTitle()
          @element.find('.sheetTitle').blur()
          prevTitle = curTitle
          return false
    .focusout (e) =>
      curTitle = @element.find('.sheetTitle').html()
      @socketSetTitle() if prevTitle isnt curTitle
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

  socketSetLink: (to_id) ->
    wallSocket.send {action : 'setLink', params: {id: @id, to_id: to_id}}
    
  socketRemoveLink: (to_id) ->
    wallSocket.send {action : 'removeLink', params: {id: @id, to_id: to_id}}

  attachHandler: () ->

  move: (params) ->
    @tXY(params.x, params.y)
    @refreshLinks(params.x, params.y, @w(), @h())
    minimap.refresh {
      id: params.id
      x: params.x
      y: params.y
      w: @w()
      h: @h()
      isTransition: true
    }

  resize: (params) ->
    @tiWH(params.width, params.height)
    @refreshLinks(@x(), @y(), params.width, params.height)
    minimap.refresh {
      id: params.id
      x: @x()
      y: @y()
      w: params.width
      h: params.height
      isTransition: true
    }

  remove: (params) ->
    for id, link of @links
      link.element.transition {opacity:0, scale: 1.25}, =>
        link.remove()
    @links = null

    @element.transition {opacity: 0, scale : 1.25}, =>
      @element.remove()
      miniSheets[@id].remove()
      glob.activeSheet = null
      #miniSheets[@id] = null
      #sheets[@id] = null
      #memory is leaking!
      #minimap.refresh() 함수에서 징징댐
    
    @element.off 'mousemove'
    @element.off 'mouseup'
    @element.off 'mousedown'

  setTitle: (params) ->
    @element.find('.sheetTitle').html(params.title)

  becomeActive: () ->
    glob.activeSheet = this
    @element.find('.boxClose').show()
    @element.children('.sheet').css 'border-top', '3px solid #FF4E58'
    @element.children('.sheet').css 'margin-top', '-3px'
    @element.find('.sheetTopBar').show()
    #@element.find('.sheetTextField').focus()
    miniSheets[@id].becomeActive()

  resignActive: () ->
    glob.activeSheet = null
    @element.find('.boxClose').hide()
    @element.children('.sheet[contentType="image"]').children('.sheetTopBar').hide()
    @element.children('.sheet').css 'border-top', ''
    @element.children('.sheet').css 'margin-top', ''
    @element.find('.sheetTextField').blur()
    @element.find('.sheetTitle').blur()
    miniSheets[@id].resignActive()

  becomeSelected: () ->
    @element.children('.sheet').css {'background-color': '#CFD2FF'}

  resignSelected: () ->
    @element.children('.sheet').css {'background-color': 'white'}

  setLink: (params) ->
    @newLinkLine = new LinkLine(@id)
    @newLinkLine.connect(params.to_id)

  removeLink: (params) ->
    @links[params.to_id].remove()
    delete @links[params.to_id]
    delete sheets[params.to_id].links[params.from_id]

  refreshLinks: (x, y, w, h) ->
    for id, link of @links
      link.transitionRefresh(@id, x, y, w, h)

  dock: () ->
    wall.dock(this)
    @resignActive()
    @docked = true

  undock: () ->
    wall.undock(this)
    @docked = false
