class WallSocket extends window.EventDispatcher
  constructor: (url) ->
    super
    @timestamp = 999
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    socket = new WS(url)

    @send = (msg) ->
      socket.send(JSON.stringify(msg))

    @close = () =>
      socket.close

    onReceive = (e) ->
      data = JSON.parse(e.data)
      
      if data.error
        console.log('disconnected: ' + data.error)
        socket.close()
        return
      
      if data.kind == "action" and timestamp < data.timestamp
        detail = JSON.parse(data.detail)
        self.trigger('receive', detail)
        timestamp = data.timestamp;

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