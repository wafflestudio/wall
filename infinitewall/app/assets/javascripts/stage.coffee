define [
  "jquery",
  "sheet/textSheet",
  "sheet/imageSheet",
  "wall",
  "minimap",
  "menu",
  "search",
  "statusbar",
  "wallsocket",
  "chat",
  "jquery.fileupload",
  ], ($, TextSheet, ImageSheet, Wall, Minimap, Menu, Search, Statusbar, WallSocket, Chat) ->
  class Stage
    currentUser: null
    activeSheet: null
    hoverSheet: null
    draggingSheet: null
    linkFromSheet: null
    stickyMenu: null
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
    zCount: 1

    createSheet: (sheetId, params, timestamp) ->
      switch params.contentType
        when @contentTypeEnum.text then new TextSheet($.extend(params, {id : sheetId}), timestamp)
        when @contentTypeEnum.image then new ImageSheet($.extend(params, {id : sheetId}))

    createSheetLink: (params, timestamp) ->
      @sheets[params.fromSheetId].setLink(params)

    constructor: (wallId, timestamp, currentUser, wallSocketURLs, chatURL) ->
      window.wall = new Wall()
      window.minimap = new Minimap()
      window.menu = new Menu()
      window.search = new Search()
      window.statusbar = new Statusbar()
      window.wallSocket = new WallSocket(wallSocketURLs, timestamp)
      window.chat = new Chat(chatURL)
      @wallId = wallId
      @currentUser = currentUser
      @stickyMenu = $("#stickyMenu")

      $(document).bind "contextmenu", -> return false
      $(window).resize -> minimap.refresh()
      $('#fileupload').fileupload  {
        dataType: 'json'
        #sequentialUploads: true
        add: (e, data) ->
          console.log "add!"
          console.log e
          $.each data.files, (index, file) ->
            data.context = statusbar.addStatus("#{file.name}", "0%")
            data.submit()
        change: (e, data) ->
          console.log "change"
          statusbar.instantStatus("Hint: Drag and dropping works! :)", 3500)
        progress : (e, data) ->
          console.log "progress"
          progress = parseInt(data.loaded / data.total * 100) + "%"
          data.context.changeRightText(progress)
        done : (e, data) ->
          console.log "done"
          $.each(data.result, (index, file) ->
            data.context.changeText("Loading " + file.name, "")
            ImageSheet.create file.name.replace(/\.[^/.]+$/, ""), "/upload/#{file.name}", =>
              statusbar.removeStatus(data.context.id, 0)
              data.context = null
          )
      }
