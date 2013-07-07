define ["movable", "linkLine", "jquery"], (Movable, LinkLine, $) ->
  class Sheet extends Movable
    links: null
    currentLink: null
    docked: false

    @create: (content) ->
      #interface for random creation
      #
    setElement: (params) ->

    constructor: (params) ->
      super(true)
      @id = params.sheetId
      @setElement()
      @xyiwh(params.x, params.y, params.width, params.height)

      @element.attr 'id', 'sheet' + @id
      @links = new Object()
      
      prevTitle = params.title

      @element.find('.sheetTitle').keydown (e) =>
        curTitle = @element.find('.sheetTitle').html()
        if e.keyCode is 13
          curTitle = msg.substr(0, msg.length - 1) if curTitle.charAt(curTitle.length - 1) is '\n'
          if prevTitle isnt curTitle
            @socketSetTitle(curTitle, prevTitle)
            @innerElement.find('.sheetTitle').blur()
            prevTitle = curTitle
            return false
      .focusout (e) =>
        curTitle = @innerElement.find('.sheetTitle').html()
        @socketSetTitle(curTitle, prevTitle) if prevTitle isnt curTitle
        prevTitle = curTitle
      .html(params.title)
      @attachHandler()

      stage.miniSheets[@id] = minimap.createMiniSheet(params)
      stage.sheets[@id] = this
      minimap.refresh()

    type: ->
      @element.attr('contentType')
     
    socketMove: (params, histParams) ->
      action = {action : 'move', params : $.extend(params, {sheetId : @id})}
      histObj = {action : 'move', params : $.extend(histParams, {sheetId: @id})}
      wallSocket.sendAction(action, histObj)

    socketResize: (params, histParams) ->
      action = {action : 'resize', params : $.extend(params, {sheetId : @id})}
      histObj = {action : 'resize', params : $.extend(histParams, {sheetId: @id})}
      wallSocket.sendAction(action, histObj)

    socketRemove: ->
      prevTitle = ""#FIXME
      prevContent = @savedText

      action = {action : 'remove', params : {sheetId : @id}}
      histObj = {action:"create", params:{x:@x, y:@y, width:@w, height:@h, title:prevTitle, contentType:"text", content:prevContent}}
      wallSocket.sendAction(action, histObj)

    socketSetTitle: (curTitle, prevTitle) ->
      action = {action : 'setTitle', params : {sheetId : @id, title : curTitle}}
      histObj = {action : 'setTitle', params : {sheetId : @id, title : prevTitle}}
      wallSocket.sendAction(action, histObj)

    socketSetLink: (toSheetId) ->
      action = {action : 'setLink', params: {sheetId: @id, fromSheetId: @id, toSheetId: toSheetId}}
      histObj = {action : 'removeLink', params: {sheetId: @id, fromSheetId: @id, toSheetId: toSheetId}}
      wallSocket.sendAction(action, histObj)
      
    socketRemoveLink: (toSheetId) ->
      action = {action : 'removeLink', params: {sheetId: @id, fromSheetId: @id, toSheetId: toSheetId}}
      histObj = {action : 'setLink', params: {sheetId: @id, fromSheetId: @id, toSheetId: toSheetId}}
      wallSocket.sendAction(action, histObj)

    attachHandler: ->

    move: (params) ->
      console.info("TT")
      console.info(params)
      if this is stage.activeSheet # 내가 이 시트를 보고있는데 누가 이걸 움직인다면
        newX = wall.mL.x + @x - params.x
        newY = wall.mL.y + @y - params.y
        wall.mL.txy(newX, newY)

      @txy(params.x, params.y)
      @refreshLinks(params.x, params.y, @w, @h)

      minimap.refresh {
        id: params.sheetId
        x: params.x
        y: params.y
        w: @w
        h: @h
        isTransition: true
      }

    resize: (params) ->
      @tiWH(params.width, params.height)
      @refreshLinks(@x, @y, params.width, params.height)
      minimap.refresh {
        id: params.sheetId
        x: @x
        y: @y
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
      @innerElement.addClass("activeSheet")
      stage.miniSheets[@id].becomeActive()
      menu.activateDelete()

    resignActive: ->
      stage.activeSheet = null
      @innerElement.removeClass("activeSheet")
      @element.find('.sheetTextField').blur()
      @element.find('.sheetTitle').blur()
      stage.miniSheets[@id].resignActive()
      menu.deactivateDelete()

    becomeSelected: ->
      @innerElement.addClass("selectedSheet")

    resignSelected: ->
      @innerElement.removeClass("selectedSheet")

    setLink: (params) ->
      @newLinkLine = new LinkLine(@id)
      @newLinkLine.connect(params.toSheetId)

    removeLink: (params) ->
      @links[params.toSheetId].remove()
      delete @links[params.toSheetId]
      delete stage.sheets[params.toSheetId].links[params.fromSheetId]

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
