class window.Sheet extends Movable
  links: null
  currentLink: null
  docked: false

  @create: (content) ->
    #interface for random creation
  setElement: (params) ->
  constructor: (params) ->
    @id = params.id
    @setElement()
    @xyiwh(params.x, params.y, params.width, params.height)

    @element.attr 'id', 'sheet' + params.id
    @links = new Object()
    
    prevTitle = params.title

    @element.find('.sheetTitle').keydown (e) =>
      curTitle = @element.find('.sheetTitle').html()
      if e.keyCode is 13
        curTitle = msg.substr(0, msg.length - 1) if curTitle.charAt(curTitle.length - 1) is '\n'
        if prevTitle isnt curTitle
          @socketSetTitle()
          @innerElement.find('.sheetTitle').blur()
          prevTitle = curTitle
          return false
    .focusout (e) =>
      curTitle = @innerElement.find('.sheetTitle').html()
      @socketSetTitle() if prevTitle isnt curTitle
      prevTitle = curTitle
    .html(params.title)
    @attachHandler()
    
    stage.miniSheets[@id] = minimap.createMiniSheet(params)
    stage.sheets[params.id] = this
    minimap.refresh()

  type: ->
    @element.attr('contentType')
   
  socketMove: (params) ->
    wallSocket.send {action : 'move', params : $.extend(params, {id : @id})}

  socketResize: (params) ->
    wallSocket.send {action : 'resize', params : $.extend(params, {id : @id})}

  socketRemove: ->
    wallSocket.send {action : 'remove', params : {id : @id}}

  socketSetTitle: ->
    wallSocket.send {action : 'setTitle', params : {id : @id, title : @element.find('.sheetTitle').html()}}

  socketSetLink: (to_id) ->
    wallSocket.send {action : 'setLink', params: {id: @id, to_id: to_id}}
    
  socketRemoveLink: (to_id) ->
    wallSocket.send {action : 'removeLink', params: {id: @id, to_id: to_id}}

  attachHandler: ->

  move: (params) ->
    if this is stage.activeSheet # 내가 이 시트를 보고있는데 누가 이걸 움직인다면
      newX = wall.mL.x() + @x() - params.x
      newY = wall.mL.y() + @y() - params.y
      wall.mL.txy(newX, newY)

    @txy(params.x, params.y)
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
      #link.socketRemoveLink()
      link.remove()
    @links = null

    @element.transition {opacity: 0, scale : 1.25}, =>
      @element.remove()
      stage.miniSheets[@id].remove()
      stage.activeSheet = null
      delete stage.sheets[@id]
      delete stage.miniSheets[@id]
    
    @element.off 'mousemove'
    @element.off 'mouseup'
    @element.off 'mousedown'

  setTitle: (params) ->
    @element.find('.sheetTitle').html(params.title)

  becomeActive: ->
    stage.activeSheet = this
    @innerElement.css 'border-top', '3px solid #FF4E58'
    @innerElement.css 'margin-top', '-3px'
    #@element.find('.sheetTextField').focus()
    stage.miniSheets[@id].becomeActive()
    menu.activateDelete()

  resignActive: ->
    stage.activeSheet = null
    @innerElement.css 'border-top', ''
    @innerElement.css 'margin-top', ''
    @element.find('.sheetTextField').blur()
    @element.find('.sheetTitle').blur()
    stage.miniSheets[@id].resignActive()
    menu.deactivateDelete()

  becomeSelected: ->
    @innerElement.css {'background-color': '#CFD2FF'}

  resignSelected: ->
    @innerElement.css {'background-color': 'white'}

  setLink: (params) ->
    @newLinkLine = new LinkLine(@id)
    @newLinkLine.connect(params.to_id)

  removeLink: (params) ->
    @links[params.to_id].remove()
    delete @links[params.to_id]
    delete stage.sheets[params.to_id].links[params.from_id]

  refreshLinks: (x, y, w, h) ->
    for id, link of @links
      link.transitionRefresh(@id, x, y, w, h)

  dock: ->
    wall.dock(this)
    @resignActive()
    @docked = true

  undock: ->
    wall.undock(this)
    @docked = false

  glow: ->
    temp = "3px 4px 4px 2px #888"
    blur = 40 / stage.zoom
    spread = 30 / stage.zoom
    console.log "#{blur}, #{spread}"
    @innerElement.animate {'box-shadow': "0px 0px #{150 / stage.zoom}px 20px #FF9F88"}, =>
    @innerElement.animate {'box-shadow': temp}, =>
    @innerElement.animate {'box-shadow': "0px 0px #{150 / stage.zoom}px 20px #FF9F88"}, =>
    @innerElement.animate {'box-shadow': temp}, =>
    @innerElement.animate {'box-shadow': "0px 0px #{150 / stage.zoom}px 20px #FF9F88"}, =>
    @innerElement.animate {'box-shadow': temp}
