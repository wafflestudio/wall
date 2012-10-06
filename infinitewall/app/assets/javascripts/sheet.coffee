class window.Sheet
  sheet_id: null
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
    @element.css 'x', params.x + 'px'
    @element.css 'y', params.y + 'px'
    @element.css 'outline', 'none'

    @element.children('.sheet').css 'width', params.width + 'px'
    @element.children('.sheet').css 'height', params.height + 'px'
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
   
    @attachSocketAction()
    @attachHandler()

    newMiniSheet = $($('<div class = "minimapElement"></div>').appendTo('#minimapWorld'))
    newMiniSheet.attr('id', 'map_sheet' + @id)
    setMinimap()

    window.sheets[params.id] = this

  attachSocketAction: () ->
    self = this
    @element.on 'move', (e, params) ->
      wallSocket.send {action : 'move', params : $.extend(params, {id : self.id})}

    @element.on 'resize', (e, params) ->
      wallSocket.send {action : 'resize', params : $.extend(params, {id : self.id})}

    @element.on 'remove', (e) ->
      wallSocket.send {action : 'remove', params : {id : self.id}}

    @element.on 'setTitle', (e) ->
      wallSocket.send {action : 'setTitle', params : {id : self.id, title : self.element.find('.sheetTitle').html()}}

  attachHandler: () ->
    #@handler = new SheetHandler(this)

  move: (params) ->
    #move sheet
    @element.css 'x', params.x
    @element.css 'y', params.y

  resize: (params) ->
    #resize sheet
    @element.children('.sheet').css('width', params.width)
    @element.children('.sheet').css('height', params.height)

  remove: (params) ->
    #remove sheet 
    @element.remove()
    @element.off 'mousemove'
    @element.off 'mouseup'
    @element.off 'mousedown'
    $('#map_sheet' + params.id).remove()

  setTitle: (params) ->
    #set title of sheet
    @element.find('.sheetTitle').html(params.title)
