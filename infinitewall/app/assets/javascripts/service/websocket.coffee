# required for extending:
# @url
# @scope

# states: CONNECTED <=> TRYING
define ["common/EventDispatcher", "jquery", "./cometsocket", "./connection"], (EventDispatcher, $, CometSocket, Connection) ->

  # get websocket url adjusted to current viewing protocol (http->ws/https->wss)
  websocketURLAdjusted = (url) ->
    if location.protocol == "https:"
      protocol = "wss:"
    else
      protocol = "ws:"

    if url.match(/^wss:\/\//)? or url.match(/^ws:\/\//)?
      url = url.replace(/^(wss|ws):\/\//,  protocol + "//")
    else
      url = protocol + "//" + url

    url


  class PersistentWebsocket extends EventDispatcher

    generateUUID: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = Math.random()*16|0
        v = if c == 'x' then r else (r&0x3|0x8)
        v.toString(16)
      ) + "-" + new Date().getTime().toString(36)
    
    constructor: (@url, @cometurls) ->
      super()
      @WS = if window['MozWebSocket'] then MozWebSocket else window['WebSocket']
      @status = "TRYING"
      @numRetry = 0
      @scope = "[???]"
      @buffered = [] # emergency buffer
      @pending = []

      @uuid = @generateUUID()
      #@comet = new CometSocket(@cometurls.speak + "?uuid=#{@uuid}", cometurls.listen +"?uuid=#{@uuid}", "COMET")

      @connections = {}

      @url = websocketURLAdjusted(@url)

      if @WS?
        @connect()
      else
        setTimeout (() => @trigger('close')), 0

    isConnected:() ->
      @status == "CONNECTED"

    connect: ()=>
      console.info("[WS]", "Trying to connect... ", @numRetry) if @numRetry > 0
      @socket = new @WS(@url)
      @socket.onopen = @onOpen
      @socket.onerror = @onError
      @socket.onclose = @onClose

    join: (path, timestamp) ->
      unless @connections[path]?
        conn = new Connection()
        conn.send = (msg) =>
          @send(path, msg)
        conn.isConnected = () =>
          @isConnected()
        @connections[path] = conn
      if @isConnected()
        @send(path, JSON.stringify({type:"join", path:path, uuid:@uuid, timestamp:timestamp}))
      else
        @connections[path].once('open', () =>
          @send(path, JSON.stringify({type:"join", path:path, uuid:@uuid, timestamp:timestamp}))
        )

      @connections[path]


    send: (path, msg) ->
      console.info("[WS::send]", path, "sending #{msg.length} characters", msg)
      if @isConnected()
        @socket.send(msg)
      else
        @comet.send(msg)

    close: ()->
      console.warn("[WS::close]", "this feature is not supported! Why did you do this??")
      @socket.close()

    # @override
    onReceive: (e) =>
      console.log("[WS::Receive]", e.data)
      data = JSON.parse(e.data)
      if data.path? and @connections[data.path]?
        @connections[data.path].trigger('receive', data)
      @trigger('receive', data)

    onOpen: (e) =>
      @socket.onmessage = @onReceive
      console.info("[WS::open]", "websocket connection established: ", e)
      @trigger('open', e)
      @status = "CONNECTED"
      @numRetry = 0

      #@comet.deactivate()
      #@comet.off 'receive', @onReceive

      if @pending.length > 0
        console.info(@scope, "sending #{@pending.length} unsent messages")
        for msg in @pending
          @socket.send(JSON.stringify(msg))

      for path,connection of @connections
        connection.trigger('open', e)


    onClose: (e) =>
      @status = "TRYING"
      @socket.onclose = null
      @socket.onopen = null
      @socket.onmessage = null
      @socket.onerror = null

      setTimeout(@connect, Math.pow(2, @numRetry) * 1000)
      @numRetry += 1 if @numRetry < 5
      console.warn("[WS::onClose]", "websocket connection closed: ", e, "Will retry connect")

      #@comet.activate()
      #@comet.on 'receive', @onReceive
      ###if @pending.length > 0
        console.info(@scope, "sending #{@pending.length} unsent messages")
        for msg in @pending
          @comet.send(JSON.stringify(msg))
      ###


      for path,connection of @connections
        connection.trigger('close', e)
      @trigger('close', e)

    onError: (e) =>
      if @status == "TRYING"
        console.warn("[WS::onError]", "websocket cannot establish connnection: ", e)
      else
        console.error("[WS::onError]", "websocket connection caught an error: ", e)

      for path,connection of @connections
        connection.trigger('error', e)

      @trigger('error', e)
