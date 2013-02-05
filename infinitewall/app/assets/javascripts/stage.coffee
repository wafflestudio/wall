class window.Stage
  currentUser: null
  activeSheet: null
  hoverSheet: null
  linkFromSheet: null
  leftClick: false
  rightClick: false
  zoom: 1
  scaleLayerX: 0
  scaleLayerY: 0
  wallId: 0
  moveID: null
  sheets: {}
  miniSheets: {}
  contentTypeEnum: {
    text: "text"
    image: "image"
  }

  createSheet: (id, params, timestamp) ->
    switch params.contentType
      when @contentTypeEnum.text then new TextSheet($.extend(params, {id : id}), timestamp)
      when @contentTypeEnum.image then new ImageSheet($.extend(params, {id : id}))

  createSheetLink: (params, timestamp) ->
    @sheets[params.from_id].setLink(params)

  constructor: (wallId, timestamp, currentUser, wallSocketURL, chatURL) ->
    window.wall = new Wall()
    window.minimap = new Minimap()
    window.menu = new Menu()
    window.statusbar = new Statusbar()
    window.wallSocket = new WallSocket(wallSocketURL, timestamp)
    window.chat = new Chat(chatURL)
    @wallId = wallId
    @currentUser = currentUser

    $(document).bind "contextmenu", -> return false
    $(window).resize -> minimap.refresh()
    $('#fileupload').fileupload  {
      dataType: 'json'
      #sequentialUploads: true
      add: (e, data) ->
        $.each data.files, (index, file) ->
          data.context = statusbar.addStatus("#{file.name}", "0%")
          data.submit()
      change: (e, data) ->
        statusbar.instantStatus("Hint: Drag and dropping works! :)", 3500)
      progress : (e, data) ->
        progress = parseInt(data.loaded / data.total * 100) + "%"
        data.context.changeRightText(progress)
      done : (e, data) ->
        $.each(data.result, (index, file) ->
          data.context.changeText("Loading " + file.name, "")
          ImageSheet.create file.name.replace(/\.[^/.]+$/, ""), "/assets/files/#{file.name}", =>
            statusbar.removeStatus(data.context.id, 0)
            data.context = null
        )
    }
