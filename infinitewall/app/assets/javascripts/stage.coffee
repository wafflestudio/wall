define [
  "jquery",
  "shortcut/shortcut",
  "sheet/textSheet",
  "sheet/imageSheet",
  "history/history",
  "wall/wall",
  "wall/minimap",
  "wall/statusbar",
  "menu",
  "search",
  "service/websocket",
  "service/wallsocket",
  "chat/ChatManager",
  "jquery.fileupload"
  ], ($, Shortcut, TextSheet, ImageSheet, History, Wall, Minimap, Menu, Search, Statusbar, PersistentWebsocket, WallSocket, Chat) ->

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

    constructor: (wallId, timestamp, currentUser, URLs, chatRoomId) ->
      window.wall = new Wall()
      window.minimap = new Minimap()
      window.menu = new Menu()
      window.search = new Search()
      window.statusbar = new Statusbar()

      pwebsocket = new PersistentWebsocket(URLs.websocket, {speak:URLs.wallspeak, listen:URLs.walllisten})
      window.wallSocket = new WallSocket(pwebsocket, wallId, timestamp)
      window.chat = new Chat(pwebsocket, URLs, chatRoomId)
      window.shortcut = new Shortcut()
      @wallId = wallId
      @currentUser = currentUser
      @stickyMenu = $("#stickyMenu")
      @history = new History()


      $(document).bind "contextmenu", -> return false
      $(window).resize -> minimap.refresh()

      #TODO:
      edit = true

      if edit
        shortcut.onKeydown('ctrl + z, command + z', () => console.log("history undo"); @history.undo())
        shortcut.onKeydown('ctrl + shift + z, command + shift + z', () => console.log("history redo"); @history.redo())

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
