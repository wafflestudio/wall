class window.WallSocket extends EventDispatcher
  constructor: (url, timestamp) ->
    super()

    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @socket = new WS(url)
    @socket.onmessage = @onReceive
    @socket.onerror = @onError
    @socket.onclose = @onClose
    @timestamp = timestamp
    @receivedTimestamp = timestamp
    @on 'receivedAction', @onReceivedAction
    console.info("wall socket initialized to ts:#{timestamp}")
  
  send: (msg) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    @socket.send(JSON.stringify(msg))

  sendDelayed: (msg, delay) ->
    msg.timestamp = @timestamp unless msg.timestamp?
    json = JSON.stringify(msg)
    console.log("will send:" + json)
    setTimeout (=> @socket.send(json)), delay

  close: =>
    @socket.close

  onReceive: (e) =>
    data = JSON.parse(e.data)
    console.info('received:', data)
    @receivedTimestamp = data.timestamp

    if data.error
      console.log('disconnected: ' + data.error)
      @close()
      return
    
    if data.kind is "action" and @timestamp < @receivedTimestamp
      @timestamp = data.timestamp
      detail = JSON.parse(data.detail)
      @trigger('receivedAction', detail, data.mine, data.timestamp)
      @send({action:'ack'})
      
  onError: (e) =>
    console.log("error", e)
    @trigger('error', e)

  onClose: (e) =>
    console.log("close", e)
    @trigger('close', e)

  onReceivedAction: (detail, isMine, timestamp) =>
    isMine = isMine || false
    sheet = stage.sheets[detail.params.id]

    switch detail.action
      when "alterText" then sheet.alterText(detail.params, isMine, timestamp)
      when "create" then stage.createSheet(detail.id, detail.params, timestamp)
      when "move" then sheet.move(detail.params) unless isMine
      when "resize" then sheet.resize(detail.params) unless isMine
      when "remove" then sheet.remove(detail.params)
      when "setTitle" then sheet.setTitle(detail.params) unless isMine
      when "setLink" then sheet.setLink(detail.params)
      when "removeLink" then sheet.removeLink(detail.params)
