
class WallSocket extends window.EventDispatcher
  constructor: (url) ->
    super
   
    @timestamp = 999
    @receivedTimestamp = 999

    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    socket = new WS(url)

    # methods
    @send = (msg) ->
      msg.timestamp = @timestamp
      socket.send(JSON.stringify(msg))

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
        @trigger('receivedAction', detail, data.mine)
        
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
