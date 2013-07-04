define [
  "jquery",
  "sheet/textSheet",
  "sheet/imageSheet",
  "history",
  "shortcut/keyboard",
  "wall",
  "minimap",
  "menu",
  "search",
  "statusbar",
  "wallsocket",
  "chat",
  "jquery.fileupload"
  ], ($, TextSheet, ImageSheet, History, KeyboardJS, Wall, Minimap, Menu, Search, Statusbar, WallSocket, Chat) ->
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
    history: null

    createSheet: (sheetId, params, timestamp) ->
      switch params.contentType
        when @contentTypeEnum.text then new TextSheet($.extend(params, {id : sheetId}), timestamp)
        when @contentTypeEnum.image then new ImageSheet($.extend(params, {id : sheetId}))
      @history.update($.extend(params, {action: "create", timestamp: timestamp}))

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
      @history = new History()

      $(document).bind "contextmenu", -> return false
      $(window).resize -> minimap.refresh()
      $('#fileupload').fileupload  {
        dataType: 'json'
        process: [
          {
            action: 'loadImage'
            fileTypes: /^image\/(gif|jpeg|png)$/
            maxFileSize: 20000000
          },
          {
            action: 'resizeImage'
            maxWidth: 500
            maxHeight: 500
          },
          {
            action: 'saveImage'
          }
        ]
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
            ImageSheet.create file.name.replace(/\.[^/.]+$/, ""), "/upload/#{file.name}", =>
              statusbar.removeStatus(data.context.id, 0)
              data.context = null
          )
      }
      KeyboardJS.on 'ctrl + z, command + z', ->
        console.info("[UNDO, key only] CTRL + Z or COMMAND + Z pressed")
      KeyboardJS.on 'ctrl + shift + z, command + shift + z', ->
        console.info("[REDO, key only] CTRL + SHIFT + Z or COMMAND + SHIFT + Z pressed")
