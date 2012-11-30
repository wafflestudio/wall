
class WallSocket extends window.EventDispatcher
  constructor: (url, timestamp) ->
    super
   
    @timestamp = timestamp
    @receivedTimestamp = timestamp

    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    socket = new WS(url)
    console.info("wall socket initialized to ts:#{timestamp}")

    # methods
    @send = (msg) ->
      if !msg.timestamp?
        msg.timestamp = @timestamp
        
      socket.send(JSON.stringify(msg))

    @sendDelayed = (msg, delay) ->
      if !msg.timestamp?
        msg.timestamp = @timestamp

      json = JSON.stringify(msg)
      console.log("will send:" + json)
      sender = () =>
        socket.send(json)
        
      setTimeout(sender, delay)

    @close = () =>
      socket.close

    onReceive = (e) =>
      data = JSON.parse(e.data)

      console.info('received:', data)
      
      if data.error
        console.log('disconnected: ' + data.error)
        socket.close()
        return

      @receivedTimestamp = data.timestamp
      
      if data.kind == "action" and @timestamp < @receivedTimestamp
        @timestamp = data.timestamp
        detail = JSON.parse(data.detail)
        @trigger('receivedAction', detail, data.mine, data.timestamp)
        
    onError = (e) =>
      console.log("error", e)
      @trigger('error', e)

    onClose = (e) =>
      console.log("close", e)
      @trigger('close', e)
        
    socket.onmessage = onReceive
    socket.onerror = onError
    socket.onclose = onClose


window.WallSocket = WallSocket
