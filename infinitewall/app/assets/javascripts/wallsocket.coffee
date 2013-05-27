class window.WallSocket extends EventDispatcher

  @onCometReceive: (data) ->
    console.log("[COMET]", data)

  constructor: (urls, timestamp) ->
    super()
    @websocket = new window.PersistentWebsocket(urls.websocket, "WALL", timestamp)
    @comet = new window.CometSocket(urls.speak, urls.listen, "COMET", timestamp)
    @receivedTimestamp = timestamp
    @timestamp = timestamp
    @scope = @websocket.scope
    
    console.info(@scope, "wall socket initialized to ts:#{timestamp}")
    @websocket.on 'receive', @onReceive
    @on 'receivedAction', @onReceivedAction
    @websocket.on 'open', () =>
      @comet.deactivate()
      @comet.off 'receive', @onReceive

    @websocket.on 'close', () =>
      @comet.activate()
      @comet.on 'receive', @onReceive

  
  sendAction: (msg) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    if @websocket.isConnected
      @websocket.send(JSON.stringify(msg))
    else
      @cometsocket.send(JSON.stringify(msg))

  # only for debug
  sendActionDelayed: (msg, delay) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    json = JSON.stringify(msg)
    console.log(@scope, "will send:" + json)
    setTimeout (=> @sendAction(json)), delay

  onReceive: (data) =>
    console.info(@scope, 'received:', data)

    @receivedTimestamp = data.timestamp

    if data.error
      console.log(@scope, 'disconnected: ' + data.error)
      if @websocket.isConnected
        @websocket.close()
      return
    
    if data.kind is "action" and (not @timestamp? or @timestamp < @receivedTimestamp)
      @timestamp = data.timestamp
      detail = JSON.parse(data.detail)
      @trigger('receivedAction', detail, data.mine, data.timestamp)
      @sendAction({action:'ack'})
    else if data.kind is "action"
      console.warn(@scope, "received message with older timestamp: #{data.timestamp} < #{@timestamp}")
      

  onReceivedAction: (detail, isMine, timestamp) =>
    isMine = isMine || false
    sheet = stage.sheets[detail.params.sheetId]

    switch detail.action
      when "alterText" then sheet.alterText(detail.params, isMine, timestamp)
      when "create" then stage.createSheet(detail.sheetId, detail.params, timestamp)
      when "move" then sheet.move(detail.params) unless isMine
      when "resize" then sheet.resize(detail.params) unless isMine
      when "remove" then sheet.remove(detail.params)
      when "setTitle" then sheet.setTitle(detail.params) unless isMine
      when "setLink" then sheet.setLink(detail.params)
      when "removeLink" then sheet.removeLink(detail.params)
